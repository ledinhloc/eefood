import 'package:eefood/features/noti/data/models/notification_model.dart';
import 'package:eefood/features/noti/data/models/notification_settings_model.dart';
import 'package:eefood/features/noti/domain/repositories/notification_repository.dart';

class GetAllNotifications {
  final NotificationRepository repository;
  GetAllNotifications(this.repository);

  Future<List<NotificationModel>> call({int page = 1, int limit = 5}) =>
      repository.getAllNotifications(page, limit);
}

class GetUnreadCount {
  final NotificationRepository repository;
  GetUnreadCount(this.repository);

  Future<int> call() => repository.getUnreadCount();
}

class MarkAsRead {
  final NotificationRepository repository;
  MarkAsRead(this.repository);

  Future<String> call(int id) => repository.markAsRead(id);
}

class MarkAllAsRead {
  final NotificationRepository repository;
  MarkAllAsRead(this.repository);

  Future<String> call() => repository.markAllAsRead();
}

class DeleteNotification {
  final NotificationRepository repository;
  DeleteNotification(this.repository);

  Future<String> call(int id) => repository.deleteNotification(id);
}

class DeleteAllNotifications {
  final NotificationRepository repository;
  DeleteAllNotifications(this.repository);

  Future<void> call() => repository.deleteAllNotifications();
}

class GetNotificationSettings {
  final NotificationRepository repository;
  GetNotificationSettings(this.repository);

  Future<List<NotificationSettingsModel>> call() =>
      repository.getNotificationSettings();
}

class UpdateNotificationSettings {
  final NotificationRepository repository;
  UpdateNotificationSettings(this.repository);

  Future<List<NotificationSettingsModel>> call(Map<String, bool> settings) =>
      repository.updatedNotificationSettings(settings);
}
