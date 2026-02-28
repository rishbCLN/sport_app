import 'package:flutter/foundation.dart';
import '../models/user_stats.dart';
import 'auth_service.dart';

/// Singleton service that holds the current user's editable profile.
///
/// Use [instance] to read/write. Notify UI via [addListener].
class UserProfileService extends ChangeNotifier {
  static final UserProfileService _inst = UserProfileService._();
  static UserProfileService get instance => _inst;
  UserProfileService._();

  UserStats? _profile;

  UserStats get profile {
    if (_profile == null) _init();
    return _profile!;
  }

  void _init() {
    final auth = AuthService();
    _profile = UserStats(
      userId: auth.currentUserId ?? 'user_001',
      name: auth.currentUsername ?? 'PLAYER',
      photoUrl: '',
      tags: const ['#CLUTCH', '#TEAM PLAYER'],
      mainPosition: 'Striker',
      favoriteGround: 'Sand Ground',
      rollNumber: '',
    );
  }

  /// Call after successful login to seed the service with fresh auth data.
  void reset() {
    _profile = null;
    notifyListeners();
  }

  void updateProfile({
    String? name,
    String? mainPosition,
    String? favoriteGround,
    String? rollNumber,
    List<String>? tags,
  }) {
    _profile = profile.copyWith(
      name: name,
      mainPosition: mainPosition,
      favoriteGround: favoriteGround,
      rollNumber: rollNumber,
      tags: tags,
    );
    notifyListeners();
  }
}
