import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../api/admin_api.dart';
import '../views/widgets/app_notification.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[FCM Background] Message received: ${message.messageId} - ${message.notification?.title}');
}

class AdminNotificationService {
  static final AdminNotificationService _instance = AdminNotificationService._internal();
  factory AdminNotificationService() => _instance;
  AdminNotificationService._internal();

  final AdminApi _api = AdminApi();
  String? _currentFcmToken;

  Future<void> initialize() async {
    // Only initialize on supported platforms (Android / iOS / Web with config)
    try {
      if (kIsWeb) {
        // Web FCM requires vapidKey & web config, fallback gracefully
        return;
      }

      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;

      // Request notification permissions for tablet / mobile devices
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('[AdminNotification] Permission status: ${settings.authorizationStatus}');

      // Get FCM device token
      _currentFcmToken = await messaging.getToken();
      debugPrint('[AdminNotification] FCM Token: $_currentFcmToken');

      // Subscribe to admin topic for broadcast admin notifications
      try {
        await messaging.subscribeToTopic('admin-kritter');
        debugPrint('[AdminNotification] Subscribed to topic admin-kritter');
      } catch (topicError) {
        debugPrint('[AdminNotification] Subscribe to topic error: $topicError');
      }

      // Listen for incoming messages while app is in foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final title = message.notification?.title ?? message.data['title'] ?? 'Pesan Baru';
        final body = message.notification?.body ?? message.data['body'] ?? message.data['message'] ?? '';

        AppNotification.showInfo(
          title: title,
          message: body,
        );
      });

      // Token refresh listener
      messaging.onTokenRefresh.listen((newToken) {
        _currentFcmToken = newToken;
        registerTokenToBackend(newToken);
      });
    } catch (e) {
      debugPrint('[AdminNotification] Initialization warning/skip: $e');
    }
  }

  Future<void> registerTokenToBackend([String? token]) async {
    final t = token ?? _currentFcmToken;
    if (t != null && t.isNotEmpty) {
      try {
        final success = await _api.registerFcmToken(t);
        debugPrint('[AdminNotification] Register FCM token to backend: $success');
      } catch (e) {
        debugPrint('[AdminNotification] Register token error: $e');
      }
    }
  }

  Future<void> unregisterTokenFromBackend() async {
    if (_currentFcmToken != null && _currentFcmToken!.isNotEmpty) {
      try {
        await _api.unregisterFcmToken(_currentFcmToken!);
      } catch (e) {
        debugPrint('[AdminNotification] Unregister token error: $e');
      }
    }
  }
}
