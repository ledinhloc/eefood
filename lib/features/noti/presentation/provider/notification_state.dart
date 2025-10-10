import 'package:eefood/features/noti/data/models/notification_model.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final int unreadCount;
  final bool hasMore;
  final int currentPage;
  NotificationState({
    required this.notifications,
    required this.isLoading,
    required this.hasMore,
    required this.unreadCount,
    required this.currentPage,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    bool? hasMore,
    int? unreadCount,
    int? currentPage,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      unreadCount: unreadCount ?? this.unreadCount,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}