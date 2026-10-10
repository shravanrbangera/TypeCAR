import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static bool isFirebaseAvailable = false;
  static String? initErrorMessage;

  static Future<bool> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        isFirebaseAvailable = true;
        return true;
      }

      await Firebase.initializeApp();
      isFirebaseAvailable = true;
      debugPrint("Firebase initialized successfully.");
      return true;
    } catch (e) {
      isFirebaseAvailable = false;
      initErrorMessage = e.toString();
      debugPrint("Firebase initialization warning (fallback mode active): $e");
      return false;
    }
  }
}
