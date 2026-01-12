import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/noti/domain/repositories/notification_repository.dart';
import 'package:eefood/features/noti/presentation/provider/notification_settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/logger.dart';

class NotificationSettingsCubit extends Cubit<NotificationSettingsState> {
  final NotificationRepository repository = getIt<NotificationRepository>();
  final SharedPreferences prefs = getIt<SharedPreferences>();

  NotificationSettingsCubit()
    : super(NotificationSettingsState(settings: [], isLoading: false)) {
    print('NotificationSettingsCubit created: $hashCode');
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    if (state.isLoading) return;
    emit(state.copyWith(isLoading: true));
    try {
      final settings = await repository.getNotificationSettings();
      for (final s in settings) {
        await prefs.setBool('noti_setting_${s.type}', s.enabled!);
        logger.i('Show type enabled ${s.type} ${s.enabled}');
      }
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

      for (final entry in updatedSettings.entries) {
        await prefs.setBool('noti_setting_${entry.key}', entry.value);
      }

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

  Future<bool> isEnabled(String type) async {
    return prefs.getBool('noti_setting_$type') ?? true;
  }

  @override
  Future<void> close() {
    print('NotificationSettingsCubit closed: $hashCode');
    return super.close();
  }
}
