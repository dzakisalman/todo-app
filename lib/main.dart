import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

import 'controllers/task_controller.dart';
import 'screens/completion_screen.dart';
import 'screens/home_screen.dart';

Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Configure Firestore settings
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Initialize Firebase Auth with anonymous sign in
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        final userCredential = await FirebaseAuth.instance.signInAnonymously();
        print('Signed in anonymously with user: ${userCredential.user?.uid}');
      }
    } catch (e) {
      print('Error signing in anonymously: $e');
    }
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await SharedPreferences.getInstance();
    await initializeFirebase();
    Get.put(TaskController());
    runApp(MyApp());
  } catch (e) {
    print('Error in main: $e');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => HomeScreen()),
        GetPage(name: '/completion', page: () => CompletionScreen()),
      ],
    );
  }
}