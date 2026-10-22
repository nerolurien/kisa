/// Centralized enterprise constants for the Kisa mobile companion application.
class AppConstants {
  AppConstants._();

  // App Metadata
  static const String appName = 'Kisa';
  static const String appVersion = '1.0.0+1';

  // Proximity Alert Boundaries (in meters & kilometers)
  static const int proximityThresholdMeters = 100;
  static const double proximityThresholdKm = 0.10;
  static const int proximityResetMeters = 200;
  static const Duration proximityCooldown = Duration(minutes: 15);

  // Security & Rate Limiting Rules
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationSeconds = 30;
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 72;

  // Real-time GPS Tracking
  static const int gpsDistanceFilterMeters = 3;
  static const Duration gpsTimeout = Duration(seconds: 15);

  // Notification Configuration
  static const String notificationChannelId = 'kisa_proximity_channel';
  static const String notificationChannelName = 'Notifikasi Kedekatan Pasangan';
  static const String notificationChannelDescription =
      'Notifikasi otomatis saat pasanganmu berada di radius < 100 meter';
  static const int proximityNotificationId = 1001;

  // Shared Wishlist Categories
  static const List<String> todoCategories = [
    '🍿 Movie',
    '✈️ Trip',
    '🍲 Food',
    '🌱 Nest',
    '✨ Dream',
  ];

  // Todo Priority Levels
  static const List<String> todoPriorities = [
    'High',
    'Med',
    'Low',
  ];
}
