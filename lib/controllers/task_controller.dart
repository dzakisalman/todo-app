import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_model.dart';
import '../screens/completion_screen.dart';

class TaskController extends GetxController {
  static const String TASKS_KEY = 'tasks';
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

  Future<bool> _loadTasks() async {
    try {
      _isLoading = true;
      _error = '';
      update();

      final prefs = await SharedPreferences.getInstance();
      final String? taskData = prefs.getString(TASKS_KEY);

      if (taskData != null) {
        List<dynamic> decodedData = jsonDecode(taskData);
        _tasks = decodedData
            .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      _isLoading = false;
      update();
      return true;
    } catch (e) {
      _error = 'Error loading tasks: $e';
      _isLoading = false;
      _tasks.clear();
      update();
      return false;
    }
  }

  Future<bool> _saveTasks([int retryCount = 0]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          TASKS_KEY, jsonEncode(_tasks.map((e) => e.toJson()).toList()));
      _error = '';
      update();
      return true;
    } catch (e) {
      if (retryCount < MAX_RETRY_ATTEMPTS) {
        await Future.delayed(Duration(seconds: 1));
        return _saveTasks(retryCount + 1);
      }
      _error = 'Error saving tasks: $e';
      update();
      return false;
    }
  }

  Future<void> toggleTaskCompletion(int index) async {
    if (index >= 0 && index < _tasks.length) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      await _saveTasks();

      if (hasCompletedAllTasks) {
        Get.to(() => CompletionScreen());
      }
      update();
    }
  }

  Future<void> addTask(TaskModel task) async {
    if (task.title.isEmpty || task.time.isEmpty) {
      _error = 'Title and time cannot be empty';
      update();
      return;
    }

    _tasks.add(task);
    await _saveTasks();
    if (task.imagePath != null) {
      await _saveImagePath(task.id, task.imagePath!);
      await _saveImageToGallery(task.imagePath!);
    }
    await _loadTasks();
    update();
  }

  Future<void> _saveImageToGallery(String imagePath) async {
    if (await Permission.storage.request().isGranted) {
      try {
        await Gal.putImage(imagePath);
      } catch (e) {
        _error = 'Failed to save image to gallery: $e';
        update();
      }
    } else {
      _error = 'Storage permission denied';
      update();
    }
  }

  Future<void> _saveImagePath(String taskId, String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('imagePath_$taskId', path);
    update();
  }

  Future<String?> getImagePath(String taskId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('imagePath_$taskId');
  }

  Future<void> removeTask(int index) async {
    if (index >= 0 && index < _tasks.length) {
      _tasks.removeAt(index);
      await _saveTasks();
      update();
    }
  }

  Future<void> retryLoadTasks() async {
    await _loadTasks();
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
      final taskMinutes = task.getTimeInMinutes();
      return taskMinutes >= startMinutes && taskMinutes <= endMinutes;
    }).toList();

    _filteredTasks = filtered;
    update();
  }

  void filterBySearchQuery(String query) {
    _searchQuery = query;
    update();
  }
}
