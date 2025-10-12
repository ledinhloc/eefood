import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/noti/domain/repositories/notification_repository.dart';
import 'package:eefood/features/noti/presentation/provider/notification_settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationSettingsCubit extends Cubit<NotificationSettingsState> {
  final NotificationRepository repository = getIt<NotificationRepository>();

  NotificationSettingsCubit()
    : super(NotificationSettingsState(settings: [], isLoading: false)) {
    print('⚙️ NotificationSettingsCubit created: $hashCode');
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    if (state.isLoading) return;
    emit(state.copyWith(isLoading: true));
    try {
      final settings = await repository.getNotificationSettings();
      emit(state.copyWith(settings: settings, isLoading: false));
    } catch (err) {
      print('Error updating notification settings: $err');
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> updateSettings(Map<String, bool> updatedSettings) async {
    try {
      emit(state.copyWith(isLoading: true));
      await repository.updatedNotificationSettings(updatedSettings);
      final newSettings = state.settings.map((setting) {
        if (updatedSettings.containsKey(setting.type)) {
          return setting.copyWith(enabled: updatedSettings[setting.type]!);
        }
        return setting;
      }).toList();
      emit(state.copyWith(settings: newSettings, isLoading: false));
    } catch (err) {
      print('Error updating notification settings: $err');
      emit(state.copyWith(isLoading: false));
    }
  }

  @override
  Future<void> close() {
    print('NotificationSettingsCubit closed: $hashCode');
    return super.close();
  }
}
