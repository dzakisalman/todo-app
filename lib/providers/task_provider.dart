import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_model.dart';
import '../screens/completion_screen.dart';

class TaskProvider with ChangeNotifier {
  static const String TASKS_KEY = 'tasks';
  static const int MAX_RETRY_ATTEMPTS = 3;

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<TaskModel> get tasks => _tasks;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get hasCompletedAllTasks =>
      _tasks.isNotEmpty && _tasks.every((task) => task.isCompleted);

  TaskProvider() {
    _loadTasks();
  }

  Future<bool> _loadTasks() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
    print('SharedPreferences instance created'); // Debug logging

      final String? taskData = prefs.getString(TASKS_KEY);
    print('Task data: $taskData'); // Debug logging

      if (taskData != null) {
        List<dynamic> decodedData = jsonDecode(taskData);
        _tasks = decodedData
            .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
            .toList();
      print('Tasks loaded: ${_tasks.length}'); // Debug logging
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
    print('Error loading tasks: $e'); // Debug logging
      _error = 'Error loading tasks: $e';
      _isLoading = false;
      _tasks = [];
      notifyListeners();
      return false;
    }
  }

  Future<bool> _saveTasks([int retryCount = 0]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          TASKS_KEY, jsonEncode(_tasks.map((e) => e.toJson()).toList()));
    _error = null;
      return true;
    } catch (e) {
      if (retryCount < MAX_RETRY_ATTEMPTS) {
        await Future.delayed(Duration(seconds: 1));
        return _saveTasks(retryCount + 1);
      }
      _error = 'Error saving tasks: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleTaskCompletion(int index, BuildContext context) async {
    if (index >= 0 && index < _tasks.length) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      await _saveTasks();
      notifyListeners();

      // Check if all tasks are completed
      if (hasCompletedAllTasks && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CompletionScreen()),
        );
      }
    }
  }

  Future<void> addTask(TaskModel task) async {
    if (task.title.isEmpty || task.time.isEmpty) {
      _error = 'Title and time cannot be empty';
      notifyListeners();
      return;
    }

    _tasks.add(task);
    await _saveTasks();
    await _saveImagePath(task.id, task.imagePath!);

    if (task.imagePath != null) {
      await _saveImagePath(task.id, task.imagePath!);
      await _saveImageToGallery(task.imagePath!);
    }
    await _loadTasks();
    notifyListeners();
  }

  Future<void> _saveImageToGallery(String imagePath) async {
    if (await Permission.storage.request().isGranted) {
      try {
        await Gal.putImage(imagePath);
      } catch (e) {
        _error = 'Failed to save image to gallery: $e';
        notifyListeners();
      }
    } else {
      _error = 'Storage permission denied';
      notifyListeners();
    }
  }

  Future<void> _saveImagePath(String taskId, String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('Saving ImagePath for Task ID: $taskId -> Path: $path'); // Debugging
    await prefs.setString('imagePath_$taskId', path);
    print(
        'Saved ImagePath: ${prefs.getString('imagePath_$taskId')}'); // Debugging
  }

  Future<String?> getImagePath(String taskId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('imagePath_$taskId');
  }

  Future<void> removeTask(int index) async {
    if (index >= 0 && index < _tasks.length) {
      _tasks.removeAt(index);
      await _saveTasks();
      notifyListeners();
    }
  }

  Future<void> retryLoadTasks() async {
    await _loadTasks();
    _error = null;
  }
}

void debugSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  print('All stored keys in SharedPreferences: ${prefs.getKeys()}');
  prefs.getKeys().forEach((key) {
    print('$key: ${prefs.get(key)}');
  });
}
