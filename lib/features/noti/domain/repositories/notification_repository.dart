import 'package:eefood/features/noti/data/models/notification_model.dart';
import 'package:eefood/features/noti/data/models/notification_settings_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getAllNotifications(int page, int limit);
  Future<int> getUnreadCount();
  Future<String> markAsRead(int id);
  Future<String> markAllAsRead();
  Future<String> deleteNotification(int id);
  Future<void> deleteAllNotifications();
  Future<List<NotificationSettingsModel>> getNotificationSettings();
  Future<List<NotificationSettingsModel>> updatedNotificationSettings(Map<String,bool> settings);
  Future<void> unregisterToken(int userId);
}