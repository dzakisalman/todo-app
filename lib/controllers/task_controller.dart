import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

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
    _loadTasks();
  }

  void _loadTasks() {
    _isLoading = true;
    _error = '';
    update();

    _firebaseService.getTasks().listen(
      (tasks) {
        _tasks = tasks;
        _isLoading = false;
        update();
      },
      onError: (error) {
        _error = 'Error loading tasks: $error';
        _isLoading = false;
        _tasks.clear();
        update();
      },
    );
  }

  Future<void> toggleTaskCompletion(int index) async {
    if (index >= 0 && index < _tasks.length) {
      final task = _tasks[index];
      final updatedTask = TaskModel(
        id: task.id,
        title: task.title,
        description: task.description,
        time: task.time,
        imageUrl: task.imageUrl,
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

  Future<void> _saveLocalImage(String taskId, String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'image_$taskId';
      await prefs.setString(key, imagePath);
      print('Local image saved for task $taskId: $imagePath');
    } catch (e) {
      print('Error saving local image: $e');
    }
  }

  Future<String?> getLocalImage(String taskId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'image_$taskId';
      final imagePath = prefs.getString(key);
      print('Retrieved local image for task $taskId: $imagePath');
      
      if (imagePath != null && File(imagePath).existsSync()) {
        return imagePath;
      }
      return null;
    } catch (e) {
      print('Error getting local image: $e');
      return null;
    }
  }

  Future<void> addTask(TaskModel task) async {
    if (task.title.isEmpty) {
      _error = 'Title cannot be empty';
      update();
      return;
    }

    try {
      // Save to Firestore
      await _firebaseService.addTask(task);
      update();
    } catch (e) {
      _error = 'Error adding task: $e';
      update();
    }
  }

  Future<String?> uploadTaskImage(File imageFile, String taskId) async {
    try {
      // Save local path first
      await _saveLocalImage(taskId, imageFile.path);
      print('Saved local image path: ${imageFile.path}');
      
      // Then upload to Firebase Storage
      final String? firebaseUrl = await _firebaseService.uploadImage(imageFile, taskId);
      print('Uploaded to Firebase, got URL: $firebaseUrl');
      
      return firebaseUrl;
    } catch (e) {
      _error = 'Error uploading image: $e';
      update();
      return null;
    }
  }

  Future<void> removeTask(int index) async {
    if (index >= 0 && index < _tasks.length) {
      final task = _tasks[index];
      try {
        // Remove from Firestore and Storage
        if (task.imageUrl != null) {
          await _firebaseService.deleteImage(task.imageUrl!);
        }
        await _firebaseService.deleteTask(task.id);

        // Remove local image
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('image_${task.id}');

        update();
      } catch (e) {
        _error = 'Error removing task: $e';
        update();
      }
    }
  }

  Future<void> retryLoadTasks() async {
    _loadTasks();
    _error = '';
    update();
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
