/// Application constants and configuration
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // Firebase collection names
  static const String usersCollection = 'users';
  static const String teamRequestsCollection = 'teamRequests';

  // Sports list
  static const List<String> sports = ['Football', 'Badminton', 'Cricket'];

  // Ground numbers
  static const List<int> groundNumbers = [1, 2, 3, 4, 5];

  // Player count options
  static const List<int> playerCounts = [1, 2, 3, 4, 5];

  // Status constants
  static const String statusActive = 'active';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // Padding and spacing
  static const double paddingSmall = 8.0;
  static const double paddingDefault = 16.0;
  static const double paddingLarge = 24.0;

  // Border radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusDefault = 12.0;
  static const double borderRadiusLarge = 16.0;

  // Animation duration
  static const Duration animationDuration = Duration(milliseconds: 300);
}
