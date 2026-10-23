import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../constants/app_constants.dart';

/// Central service for delivering high-priority proximity alerts
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize system notification channels for Android and iOS
  Future<void> initialize() async {
    if (_isInitialized || kIsWeb) return;

    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings darwinSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint(
              '[NotificationService] Notification tapped: ${response.payload}');
        },
      );

      // Request notification permissions explicitly on Android 13+
      await _requestAndroidPermissions();

      _isInitialized = true;
      debugPrint(
          '[NotificationService] Notification service initialized successfully');
    } catch (e) {
      debugPrint(
          '[NotificationService] Failed to initialize notification plugin: $e');
    }
  }

  Future<void> _requestAndroidPermissions() async {
    try {
      final androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
    } catch (e) {
      debugPrint('[NotificationService] Android permission request error: $e');
    }
  }

  /// Show proximity alert when partner is within 100 meters
  Future<void> showProximityAlert({
    required String partnerName,
    required int distanceMeters,
  }) async {
    if (kIsWeb) return;

    try {
      if (!_isInitialized) {
        await initialize();
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        styleInformation: BigTextStyleInformation(''),
      );

      const DarwinNotificationDetails darwinDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      final String title = '❤️ $partnerName Sangat Dekat Denganmu!';
      final String body = distanceMeters <= 20
          ? '$partnerName sudah berada tepat di sampingmu (< 20m) 🥰'
          : '$partnerName berjarak hanya $distanceMeters meter dari posisimu! Saatnya sapa si dia 💕';

      await _notificationsPlugin.show(
        id: AppConstants.proximityNotificationId,
        title: title,
        body: body,
        notificationDetails: platformDetails,
        payload: 'proximity_alert',
      );
    } catch (e) {
      debugPrint(
          '[NotificationService] Error displaying proximity notification: $e');
    }
  }
}
