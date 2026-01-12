import 'package:eefood/core/utils/deep_link_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../../../../core/di/injection.dart';
import '../../presentation/provider/notification_settings_cubit.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notiPlugin =
  FlutterLocalNotificationsPlugin();
  static bool _initialized = false;


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

    await _ensureInitialized();

    String? localImagePath;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      localImagePath = await _downloadAndSaveImage(avatarUrl);
    }

    final androidDetails = AndroidNotificationDetails(
      _resolveChannel(type),
      type == "SYSTEM"
          ? "System Notifications"
          : "User Interaction Notifications",
      channelDescription: "Notification Channel",
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      styleInformation: localImagePath != null
            ? BigPictureStyleInformation(
          FilePathAndroidBitmap(localImagePath),
          contentTitle: title,
          summaryText: body,
          largeIcon: FilePathAndroidBitmap(localImagePath),
          )
          : BigTextStyleInformation(body),
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


  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('ic_eefood');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notiPlugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: onActionReceived,
    );

    _initialized = true;
  }

  static Future<String?> _downloadAndSaveImage(String url) async {
    try {
      // Download image
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;

      // Lấy thư mục temporary
      final directory = await getTemporaryDirectory();

      // Tạo file name unique
      final fileName = 'notification_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${directory.path}/$fileName';

      // Lưu file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return filePath;
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
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
  final prefs = await SharedPreferences.getInstance();

  print('Handling background message: ${message.messageId}');
  print('Message data: ${message.data}');

  final type = message.data['type'] ?? 'SYSTEM';

  final isEnabled =
      prefs.getBool('noti_setting_$type') ?? true;

  if (!isEnabled) {
    print('Background notification $type is disabled');
    return;
  }

  await NotificationService._ensureInitialized();

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