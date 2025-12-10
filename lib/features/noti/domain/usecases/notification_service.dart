import 'package:eefood/core/utils/deep_link_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notiPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Android init
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('ic_eefood');

    // iOS init
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // Init plugin
    await _notiPlugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: onActionReceived,
    );

    // Request permissions
    await requestNotificationPermission();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    required String type,
    String? avatarUrl,
    String? path,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _resolveChannel(type),
      type == "SYSTEM"
          ? "System Notifications"
          : "User Interaction Notifications",
      channelDescription: "Notification Channel",
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      styleInformation: avatarUrl != null
          ? BigPictureStyleInformation(
              FilePathAndroidBitmap(avatarUrl),
              contentTitle: title,
              summaryText: body,
            )
          : null,
    );

    final iOSDetails = DarwinNotificationDetails();

    await _notiPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iOSDetails),
      payload: path,
    );
  }

  static String _resolveChannel(String type) {
    switch (type) {
      case 'COMMENT':
      case 'REACTION':
      case 'FOLLOW':
      case 'SAVE_RECIPE':
      case 'SHARE_RECIPE':
      case 'REPORT':
        return 'interaction_channel';
      case 'SYSTEM':
      default:
        return 'system_channel';
    }
  }

  static Future<void> requestNotificationPermission() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      sound: true,
      badge: true,
    );
  }

  static void handleClick(String path) {
    DeepLinkHandler.handleDeepLink(path);
  }
}

@pragma('vm:entry-point')
void onActionReceived(NotificationResponse response) {
  final path = response.payload;

  if (path != null && path.isNotEmpty) {
    DeepLinkHandler.handleDeepLink(path);
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already initialized
  await Firebase.initializeApp();

  print('Handling background message: ${message.messageId}');
  print('Message data: ${message.data}');

  // Show notification when app is in background
  await NotificationService.showNotification(
    title:
        message.data['title'] ?? message.notification?.title ?? 'Thông báo mới',
    body: message.data['body'] ?? message.notification?.body ?? '',
    type: message.data['type'] ?? 'SYSTEM',
    avatarUrl: message.data['avatarUrl'],
    path: message.data['path'],
  );
}
