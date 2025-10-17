import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:eefood/core/utils/deep_link_handler.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static Future<void> initialize() async {
    // Initialize the awesome_notifications package
    await AwesomeNotifications().initialize(
      'resource://drawable/ic_eefood', // Use default icon
      [
        NotificationChannel(
          channelKey: 'interaction_channel',
          channelName: 'User Interaction Notifications',
          channelDescription: 'Thông báo khi có tương tác với bạn',
          importance: NotificationImportance.High,
          defaultColor: const Color(0xFF4CAF50),
          ledColor: const Color(0xFF4CAF50),
          playSound: true,
          soundSource: 'resource://raw/eefood_sound',
        ),
        NotificationChannel(
          channelKey: 'system_channel',
          channelName: 'System Notifications',
          channelDescription: 'Thông báo từ hệ thống',
          importance: NotificationImportance.High,
          defaultColor: const Color(0xFF2196F3),
          ledColor: const Color(0xFF2196F3),
          playSound: true,
        ),
      ],
      debug: true,
    );

    // Yêu cầu quyền hiển thị
    await requestNotificationPermission();

    // Khi người dùng bấm vào notification
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod, 
    );
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    required String type,
    String? avatarUrl,
    String? path,
  }) async {
    final channelKey = _resolveChannel(type);
    print('🔔 [showNotification] $title - $body ($type)');

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: channelKey,
        title: title,
        body: body,
        largeIcon: avatarUrl?.isNotEmpty == true ? avatarUrl : null,
        notificationLayout: NotificationLayout.Default,
        payload: {'path': path ?? ''},
      ),
    );
  }

  static String _resolveChannel(String type) {
    switch (type) {
      case 'COMMENT':
      case 'REACTION':
      case 'FOLLOW':
      case 'SAVE_RECIPE':
      case 'SHARE_RECIPE':
        return 'interaction_channel';
      case 'SYSTEM':
      default:
        return 'system_channel';
    }
  }

  static Future<void> requestNotificationPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();

    if (!isAllowed) {
      // Với Android 13+ cần quyền POST_NOTIFICATIONS
      // Với iOS 15+ cần quyền explicit
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    // iOS-specific: yêu cầu quyền thêm (optional)
    if (Platform.isIOS) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }
}

@pragma('vm:entry-point')
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  final payload = receivedAction.payload ?? {};
  final path = payload['path'];

  if (path != null && path.isNotEmpty) {
    DeepLinkHandler.handleDeepLink(path);
  }
}
