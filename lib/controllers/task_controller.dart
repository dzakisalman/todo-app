import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image/image.dart' as img;

import '../models/task_model.dart';
import '../screens/completion_screen.dart';
import '../services/firebase_service.dart';

class TaskController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  static const String TASKS_KEY = 'tasks';
  static const String IMAGES_KEY = 'images';
  static const int MAX_RETRY_ATTEMPTS = 3;

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String _error = '';
  List<TaskModel> _filteredTasks = [];
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _searchQuery = '';

  List<TaskModel> get tasks => _tasks;

  bool get isLoading => _isLoading;

  String get error => _error;

  bool get hasCompletedAllTasks =>
      _tasks.isNotEmpty && _tasks.every((task) => task.isCompleted);

  String get searchQuery => _searchQuery;

  List<TaskModel> get filteredTasks {
    if (_searchQuery.isEmpty && _filteredTasks.isEmpty) {
      return _tasks;
    }

    var result = _tasks;

    if (_searchQuery.isNotEmpty) {
      result = result
          .where((task) =>
              task.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_filteredTasks.isNotEmpty) {
      result = result.where((task) => _filteredTasks.contains(task)).toList();
    }

    return result;
  }

  TaskController() {
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      _isLoading = true;
      _error = '';
      update();

      // Try to use existing auth first
      if (FirebaseAuth.instance.currentUser == null) {
        try {
          // Try anonymous sign in
          final userCredential = await FirebaseAuth.instance.signInAnonymously();
          print('Successfully signed in anonymously: ${userCredential.user?.uid}');
        } catch (e) {
          print('Error signing in anonymously: $e');
          _error = 'Failed to sign in: $e';
          _isLoading = false;
          update();
          return;
        }
      } else {
        print('Using existing auth: ${FirebaseAuth.instance.currentUser?.uid}');
      }

      // Start listening to tasks
      _loadTasks();
    } catch (e) {
      print('Error initializing controller: $e');
      _error = 'Error initializing app: $e';
      _isLoading = false;
      update();
    }
  }

  void _loadTasks() {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        throw Exception('Not authenticated');
      }

      _firebaseService.getTasks().listen(
        (tasks) {
          _tasks = tasks;
          _isLoading = false;
          _error = '';
          update();
        },
        onError: (error) {
          print('Error loading tasks: $error');
          _error = 'Failed to load tasks: $error';
          _isLoading = false;
          _tasks.clear();
          update();
        },
      );
    } catch (e) {
      print('Error in _loadTasks: $e');
      _error = 'Error loading tasks: $e';
      _isLoading = false;
      update();
    }
  }

  Future<void> toggleTaskCompletion(int index) async {
    if (index >= 0 && index < _tasks.length) {
      final task = _tasks[index];
      final updatedTask = TaskModel(
        id: task.id,
        title: task.title,
        description: task.description,
        time: task.time,
        imageBase64: task.imageBase64,
        isCompleted: !task.isCompleted,
      );
      
      await _firebaseService.updateTask(updatedTask);
      _tasks[index] = updatedTask;

      if (hasCompletedAllTasks) {
        Get.to(() => CompletionScreen());
      }
      update();
    }
  }

  Future<void> addTask(TaskModel task) async {
    try {
      await _ensureAuthenticated();
      await _firebaseService.addTask(task);
      _error = '';
      update();
    } catch (e) {
      print('Error adding task: $e');
      _error = 'Failed to add task: $e';
      update();
      throw e;
    }
  }

  Future<void> _ensureAuthenticated() async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        // Try anonymous sign in without signing out first
        final userCredential = await FirebaseAuth.instance.signInAnonymously();
        print('New anonymous auth: ${userCredential.user?.uid}');
      }
    } catch (e) {
      print('Error in authentication: $e');
      throw Exception('Authentication failed: $e');
    }
  }

  Future<String?> uploadTaskImage(File imageFile, String taskId) async {
    try {
      // Read and compress the image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize image if too large (max 800x800)
      img.Image resizedImage = image;
      if (image.width > 800 || image.height > 800) {
        resizedImage = img.copyResize(
          image,
          width: image.width > image.height ? 800 : null,
          height: image.height >= image.width ? 800 : null,
        );
      }

      // Compress to JPG with quality 70
      final compressedBytes = img.encodeJpg(resizedImage, quality: 70);
      
      // Convert to base64
      final base64String = base64Encode(compressedBytes);
      print('Image converted to base64 (length: ${base64String.length})');
      
      return base64String;
    } catch (e) {
      print('Error processing image: $e');
      _error = 'Error processing image: $e';
      update();
      return null;
    }
  }

  Future<void> removeTask(int index) async {
    if (index >= 0 && index < _tasks.length) {
      final task = _tasks[index];
      try {
        await _firebaseService.deleteTask(task.id);
        update();
      } catch (e) {
        _error = 'Error removing task: $e';
        update();
      }
    }
  }

  Future<void> retryLoadTasks() async {
    try {
      _error = '';
      _isLoading = true;
      update();
      
      // Try to authenticate without signing out first
      await _ensureAuthenticated();
      _loadTasks();
    } catch (e) {
      _error = 'Error retrying: $e';
      _isLoading = false;
      update();
    }
  }

  void clearTimeFilter() {
    _startTime = null;
    _endTime = null;
    _filteredTasks.clear();
    update();
  }

  void filterTasksByTimeRange(TimeOfDay? start, TimeOfDay? end) {
    if (start == null || end == null) {
      clearTimeFilter();
      return;
    }

    _startTime = start;
    _endTime = end;

    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    final filtered = _tasks.where((task) {
      final taskMinutes = task.time.hour * 60 + task.time.minute;
      return taskMinutes >= startMinutes && taskMinutes <= endMinutes;
    }).toList();

    _filteredTasks = filtered;
    update();
  }

  void filterBySearchQuery(String query) {
    _searchQuery = query;
    update();
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await _firebaseService.updateTask(task);
      update();
    } catch (e) {
      _error = 'Error updating task: $e';
      update();
    }
  }
}
