import 'dart:async';

/// Simple demo authentication service with hardcoded credentials.
class AuthService {
  static const ADMIN_USERNAME = 'admin';
  static const ADMIN_PASSWORD = 'admin';
  static const USER_USERNAME = 'user';
  static const USER_PASSWORD = 'user';

  String? currentUserId;
  String? currentUserRole; // 'admin' or 'user'
  String? currentUsername;

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Attempts login with the provided credentials.
  Future<Map<String, dynamic>> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));

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
  void logout() {
    currentUserId = null;
    currentUserRole = null;
    currentUsername = null;
  }

  bool isAdmin() => currentUserRole == 'admin';
  bool isUser() => currentUserRole == 'user';
  bool isLoggedIn() => currentUserId != null;
}
