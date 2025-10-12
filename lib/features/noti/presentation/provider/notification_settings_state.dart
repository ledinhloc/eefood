import 'package:eefood/features/noti/data/models/notification_settings_model.dart';

class NotificationSettingsState {
  final List<NotificationSettingsModel> settings;
  final bool isLoading;
  NotificationSettingsState({
    required this.settings,
    required this.isLoading,
  });

  NotificationSettingsState copyWith({
    List<NotificationSettingsModel>? settings,
    bool? isLoading,
  }) {
    return NotificationSettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}