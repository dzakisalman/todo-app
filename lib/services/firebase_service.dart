import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _ensureAuthenticated() async {
    try {
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
        print('Signed in anonymously in FirebaseService');
      }
    } catch (e) {
      print('Error in authentication: $e');
      throw Exception('Authentication failed: $e');
    }
  }

  // Menyimpan task baru
  Future<void> addTask(TaskModel task) async {
    await _ensureAuthenticated();
    try {
      await _firestore.collection('tasks').doc(task.id).set(task.toMap());
    } catch (e) {
      print('Error adding task: $e');
      throw e;
    }
  }

  // Mengambil semua task
  Stream<List<TaskModel>> getTasks() {
    if (_auth.currentUser == null) {
      throw Exception('Not authenticated');
    }

    return _firestore
        .collection('tasks')
        .orderBy('time', descending: true)
        .snapshots()
        .handleError((error) {
          print('Error in Firestore stream: $error');
          throw error;
        })
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TaskModel.fromMap({...doc.data(), 'id': doc.id}))
              .toList();
        });
  }

  // Mengupdate task
  Future<void> updateTask(TaskModel task) async {
    await _ensureAuthenticated();
    try {
      await _firestore.collection('tasks').doc(task.id).update(task.toMap());
    } catch (e) {
      print('Error updating task: $e');
      throw e;
    }
  }

  // Menghapus task
  Future<void> deleteTask(String taskId) async {
    await _ensureAuthenticated();
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      print('Error deleting task: $e');
      throw e;
    }
  }
} 