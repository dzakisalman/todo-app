import 'dart:convert';

import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_model.dart';
import '../screens/completion_screen.dart';

class TaskController extends GetxController {
  static const String TASKS_KEY = 'tasks';
  static const int MAX_RETRY_ATTEMPTS = 3;

  var _tasks = <TaskModel>[].obs;
  var _isLoading = false.obs;
  var _error = ''.obs;

  List<TaskModel> get tasks => _tasks.toList();

  bool get isLoading => _isLoading.value;

  String get error => _error.value;

  bool get hasCompletedAllTasks =>
      _tasks.isNotEmpty && _tasks.every((task) => task.isCompleted);

  TaskController() {
    _loadTasks();
  }

  Future<bool> _loadTasks() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final prefs = await SharedPreferences.getInstance();
      final String? taskData = prefs.getString(TASKS_KEY);

      if (taskData != null) {
        List<dynamic> decodedData = jsonDecode(taskData);
        _tasks.value = decodedData
            .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      _isLoading.value = false;
      return true;
    } catch (e) {
      _error.value = 'Error loading tasks: $e';
      _isLoading.value = false;
      _tasks.clear();
      return false;
    }
  }

  Future<bool> _saveTasks([int retryCount = 0]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          TASKS_KEY, jsonEncode(_tasks.map((e) => e.toJson()).toList()));
      _error.value = '';
      return true;
    } catch (e) {
      if (retryCount < MAX_RETRY_ATTEMPTS) {
        await Future.delayed(Duration(seconds: 1));
        return _saveTasks(retryCount + 1);
      }
      _error.value = 'Error saving tasks: $e';
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
    }
  }

  Future<void> addTask(TaskModel task) async {
    if (task.title.isEmpty || task.time.isEmpty) {
      _error.value = 'Title and time cannot be empty';
      return;
    }

    _tasks.add(task);
    await _saveTasks();
    if (task.imagePath != null) {
      await _saveImagePath(task.id, task.imagePath!);
      await _saveImageToGallery(task.imagePath!);
    }
    await _loadTasks();
  }

  Future<void> _saveImageToGallery(String imagePath) async {
    if (await Permission.storage.request().isGranted) {
      try {
        await Gal.putImage(imagePath);
      } catch (e) {
        _error.value = 'Failed to save image to gallery: $e';
      }
    } else {
      _error.value = 'Storage permission denied';
    }
  }

  Future<void> _saveImagePath(String taskId, String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('imagePath_$taskId', path);
  }

  Future<String?> getImagePath(String taskId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('imagePath_$taskId');
  }

  Future<void> removeTask(int index) async {
    if (index >= 0 && index < _tasks.length) {
      _tasks.removeAt(index);
      await _saveTasks();
    }
  }

  Future<void> retryLoadTasks() async {
    await _loadTasks();
    _error.value = '';
  }
}
