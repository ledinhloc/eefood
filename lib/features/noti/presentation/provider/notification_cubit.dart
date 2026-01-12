import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/noti/data/models/notification_model.dart';
import 'package:eefood/features/noti/domain/repositories/notification_repository.dart';
import 'package:eefood/features/noti/domain/usecases/notification_service.dart';
import 'package:eefood/features/noti/presentation/provider/notification_settings_cubit.dart';
import 'package:eefood/features/noti/presentation/provider/notification_state.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository repository = getIt<NotificationRepository>();
  final SharedPreferences prefs = getIt<SharedPreferences>();
  StompClient? _stompClient;
  final NotificationSettingsCubit notificationSettingsCubit =
      getIt<NotificationSettingsCubit>();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  NotificationCubit()
    : super(
        NotificationState(
          notifications: [],
          isLoading: false,
          hasMore: true,
          unreadCount: 0,
          currentPage: 1,
        ),
      ) {
    print('NotificationCubit created: $hashCode');
    initFCM();
  }

  Future<void> fetchNotifications({bool loadMore = false}) async {
    if (state.isLoading) return;
    emit(state.copyWith(isLoading: true));

    final nextPage = loadMore ? state.currentPage + 1 : 1;
    print('fetchNotifications nextPage=$nextPage, loadMore=$loadMore');
    try {
      final notifications = await repository.getAllNotifications(nextPage, 10);
      print('fetched ${notifications.length} notifications');
      emit(
        state.copyWith(
          notifications: loadMore
              ? [...state.notifications, ...notifications]
              : notifications,
          hasMore: notifications.length == 5,
          currentPage: nextPage,
          isLoading: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final count = await repository.getUnreadCount();
      emit(state.copyWith(unreadCount: count));
    } catch (_) {}
  }

  Future<void> markAsRead(int id) async {
    final updated = state.notifications.map((n) {
      if (n.id == id) {
        return NotificationModel(
          id: id,
          type: n.type,
          title: n.title,
          body: n.body,
          isRead: true,
          avatarUrl: n.avatarUrl,
          postImageUrl: n.postImageUrl,
          path: n.path,
          readAt: DateTime.now(),
          createdAt: n.createdAt,
        );
      }
      return n;
    }).toList();
    emit(state.copyWith(notifications: updated));
    await repository.markAsRead(id);
    await fetchUnreadCount();
  }

  Future<void> markAllAsRead() async {
    try {
      final updated = state.notifications.map((n) {
        return NotificationModel(
          id: n.id,
          type: n.type,
          title: n.title,
          body: n.body,
          isRead: true,
          avatarUrl: n.avatarUrl,
          postImageUrl: n.postImageUrl,
          path: n.path,
          createdAt: n.createdAt,
          readAt: DateTime.now(),
        );
      }).toList();
      emit(state.copyWith(notifications: updated, unreadCount: 0));
      await repository.markAllAsRead();
      await fetchUnreadCount();
    } catch (e) {
      print('MarkAllAsRead error: $e');
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      final updated = state.notifications.where((n) => n.id != id).toList();
      final unreadLeft = updated.where((n) => !(n.isRead ?? true)).length;

      emit(state.copyWith(notifications: updated, unreadCount: unreadLeft));
      await repository.deleteNotification(id);
      await fetchUnreadCount();
    } catch (e) {
      print('DeleteNotification error: $e');
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      emit(state.copyWith(notifications: [], unreadCount: 0));
      await repository.deleteAllNotifications();
      await fetchUnreadCount();
    } catch (e) {
      print('DeleteAllNotifications error: $e');
    }
  }

  Future<void> initFCM() async {
    // Request Permission (foreground)
    await NotificationService.requestNotificationPermission();
    // Lắng nghe thông báo foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) async {
      print('FCM Received in foreground: ${msg.data}');

      final type = msg.data['type'] ?? 'SYSTEM';

      final isEnabled = await notificationSettingsCubit.isEnabled(type);

      if (!isEnabled) {
        print('Notification $type is disabled');
        return;
      }

      final json = NotificationModel.fromJson(msg.data);

      NotificationService.showNotification(
        title: json.title ?? "Thông báo mới",
        body: json.body ?? "",
        type: json.type,
        avatarUrl: json.avatarUrl,
        path: json.path,
      );

      emit(
        state.copyWith(
          notifications: [json, ...state.notifications],
          unreadCount: state.unreadCount + 1,
        ),
      );
    });

    // Khi user bấm vào thông báo và mở app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
      print("User opened notification");
      if (msg.data["path"] != null) {
        NotificationService.handleClick(msg.data["path"]);
      }
    });

    // Khi app bị kill sau đó mở từ notification
    final initialMsg = await _messaging.getInitialMessage();
    if (initialMsg != null) {
      final path = initialMsg.data["path"];
      if (path != null) NotificationService.handleClick(path);
    }
  }

  @override
  Future<void> close() {
    print('NotificationCubit closed: $hashCode');
    return super.close();
  }
}
