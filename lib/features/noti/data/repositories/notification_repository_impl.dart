import 'package:dio/dio.dart';
import 'package:eefood/features/noti/data/models/notification_model.dart';
import 'package:eefood/features/noti/data/models/notification_settings_model.dart';
import 'package:eefood/features/noti/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl extends NotificationRepository {
  final Dio dio;
  NotificationRepositoryImpl({required this.dio});

  @override
  Future<List<NotificationModel>> getAllNotifications(
    int page,
    int limit,
  ) async {
    final response = await dio.get(
      '/v1/notifications',
      queryParameters: {'page': page, 'limit': limit},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    print('🔎 getAllNotifications response.data = ${response.data}');
    final data = response.data['data']['content'] as List<dynamic>;
    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await dio.get(
      '/v1/notifications/unread-count',
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    return response.data['data'] as int;
  }

  @override
  Future<String> markAsRead(int notificationId) async {
    final response = await dio.put(
      '/v1/notifications/$notificationId/read',
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    return response.data['message'] as String;
  }

  @override
  Future<String> markAllAsRead() async {
    final response = await dio.put(
      '/v1/notifications/read-all',
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    return response.data['message'] as String;
  }

  @override
  Future<String> deleteNotification(int notificationId) async {
    final response = await dio.delete(
      '/v1/notifications/$notificationId',
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    return response.data['message'] as String;
  }

  @override
  Future<void> deleteAllNotifications() async {
    await dio.delete(
      '/v1/notifications/delete-all',
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
  }

  @override
  Future<List<NotificationSettingsModel>> getNotificationSettings() async {
    final response = await dio.get(
      '/v1/notifications/settings',
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => NotificationSettingsModel.fromJson(e)).toList();
  }

  @override
  Future<List<NotificationSettingsModel>> updatedNotificationSettings(Map<String, bool> settings) async {
    final response = await dio.put(
      '/v1/notifications/settings/update',
      data: settings,
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => NotificationSettingsModel.fromJson(e)).toList();
  }
}
