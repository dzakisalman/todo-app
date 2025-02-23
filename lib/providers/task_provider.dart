import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task_model.dart';
import '../screens/completion_screen.dart';

class TaskProvider with ChangeNotifier {
  static const String TASKS_KEY = 'tasks';
  static const int MAX_RETRY_ATTEMPTS = 3;

  List<TaskModel> _tasks = [];
  bool _isLoading = false;  // Initialize as false
  String? _error;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCompletedAllTasks => _tasks.isNotEmpty && _tasks.every((task) => task.isCompleted);

  TaskProvider() {
    _loadTasks();
  }

  Future<bool> _loadTasks() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final String? taskData = prefs.getString(TASKS_KEY);
      
      if (taskData != null) {
        List<dynamic> decodedData = jsonDecode(taskData);
        _tasks = decodedData.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
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
      await prefs.setString(TASKS_KEY, jsonEncode(_tasks.map((e) => e.toJson()).toList()));
      return true;
    } catch (e) {
      if (retryCount < MAX_RETRY_ATTEMPTS) {
        await Future.delayed(Duration(seconds: 1)); // Wait before retry
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
      if (hasCompletedAllTasks) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CompletionScreen()),
        );
      }
    }
  }

  Future<void> addTask(TaskModel task) async {
    _tasks.add(task);
    await _saveTasks();
    notifyListeners();
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
  }
}
