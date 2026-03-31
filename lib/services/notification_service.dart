import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../controllers/notifications_controller.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Android notification channel for FCM
const _androidChannel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get and store the FCM token
    final token = await _messaging.getToken();
    if (token != null) {
      StorageService().fcmToken = token;
      if (kDebugMode) print('FCM Token: $token');
    }

    // Listen for token refresh — also sync to backend
    _messaging.onTokenRefresh.listen((newToken) {
      StorageService().fcmToken = newToken;
      if (kDebugMode) print('FCM Token refreshed: $newToken');
      _syncTokenToBackend(newToken);
    });

    // Create the Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    // Initialize flutter_local_notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // Handle foreground messages — show them via local notifications
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background/terminated tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    // Check if app was opened from a notification (terminated state)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageTap(initialMessage);
    }
  }

  /// Send updated FCM token to backend so notifications can reach this device.
  void _syncTokenToBackend(String token) {
    if (StorageService().authToken == null) return;
    ApiService().syncFcmToken(token).catchError((e) {
      if (kDebugMode) print('FCM: failed to sync token to backend: $e');
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    if (kDebugMode) {
      print('Foreground notification: ${notification.title}');
    }

    // Refresh notifications list so bell badge updates
    if (Get.isRegistered<NotificationsController>()) {
      Get.find<NotificationsController>().fetchNotifications();
    }

    // Show the notification using flutter_local_notifications
    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  void _handleMessageTap(RemoteMessage message) {
    if (kDebugMode) {
      print('Notification tapped: ${message.data}');
    }
  }
}

/// Top-level handler for background messages (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('Background notification: ${message.notification?.title}');
  }
}
