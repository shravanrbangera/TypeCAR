import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'firebase_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth? _firebaseAuth;
  String? _currentUserId;
  bool _isAnonymous = true;
  bool _isInitialized = false;

  AuthService([this._firebaseAuth]);

  String get currentUserId => _currentUserId ?? 'guest_${const Uuid().v4().substring(0, 8)}';
  bool get isAnonymous => _isAnonymous;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (FirebaseService.isFirebaseAvailable) {
      try {
        final auth = _firebaseAuth ?? FirebaseAuth.instance;
        User? user = auth.currentUser;
        if (user == null) {
          final userCredential = await auth.signInAnonymously();
          user = userCredential.user;
        }
        if (user != null) {
          _currentUserId = user.uid;
          _isAnonymous = user.isAnonymous;
          _isInitialized = true;
          debugPrint("Authenticated as Firebase user: $_currentUserId");
          notifyListeners();
          return;
        }
      } catch (e) {
        debugPrint("Firebase Auth signInAnonymously failed, using guest UUID: $e");
      }
    }

    // Offline / Local guest fallback
    _currentUserId ??= 'local_${const Uuid().v4().substring(0, 8)}';
    _isAnonymous = true;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> signInAnonymously() async {
    await initialize();
  }
}
