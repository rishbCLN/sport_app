import 'dart:async';
import '../config/backend_config.dart';
import 'firebase_auth_repository.dart';

/// Authentication service with optional Firebase backend.
class AuthService {
  static const ADMIN_USERNAME = 'admin';
  static const ADMIN_PASSWORD = 'admin';
  static const USER_USERNAME = 'user';
  static const USER_PASSWORD = 'user';

  String? currentUserId;
  String? currentUserRole; // 'admin' or 'user'
  String? currentUsername;

  FirebaseAuthRepository? _firebaseRepo;

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Attempts login with the provided credentials.
  /// When [useFirebaseBackend] is true, treats username as email and
  /// authenticates against Firebase Auth. Admin role is assigned if the
  /// email is present in [adminEmails].
  Future<Map<String, dynamic>> login(String username, String password) async {
    if (useFirebaseBackend) {
      _firebaseRepo ??= FirebaseAuthRepository();
      try {
        final cred = await _firebaseRepo!.signInWithEmailAndPassword(
          email: username,
          password: password,
        );
        final email = cred.user?.email ?? username;
        currentUserId = cred.user?.uid ?? email;
        currentUsername = email.split('@').first;
        currentUserRole = adminEmails.contains(email.toLowerCase()) ? 'admin' : 'user';
        return {'success': true, 'role': currentUserRole};
      } on Object catch (e) {
        return {'success': false, 'error': 'Login failed: $e'};
      }
    }

    await Future.delayed(const Duration(milliseconds: 300));

    if (username == ADMIN_USERNAME && password == ADMIN_PASSWORD) {
      currentUserId = 'admin_001';
      currentUserRole = 'admin';
      currentUsername = 'Admin';
      return {'success': true, 'role': 'admin'};
    } else if (username == USER_USERNAME && password == USER_PASSWORD) {
      currentUserId = 'user_001';
      currentUserRole = 'user';
      currentUsername = 'Rahul';
      return {'success': true, 'role': 'user'};
    } else {
      return {'success': false, 'error': 'Invalid credentials'};
    }
  }

  /// Clears current session data.
  Future<void> logout() async {
    if (useFirebaseBackend) {
      _firebaseRepo ??= FirebaseAuthRepository();
      await _firebaseRepo!.signOut();
    }
    currentUserId = null;
    currentUserRole = null;
    currentUsername = null;
  }

  bool isAdmin() => currentUserRole == 'admin';
  bool isUser() => currentUserRole == 'user';
  bool isLoggedIn() => currentUserId != null;
}
