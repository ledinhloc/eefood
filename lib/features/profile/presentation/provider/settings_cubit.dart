import 'package:eefood/features/profile/domain/repositories/settings_repository.dart';
import 'package:eefood/features/profile/presentation/provider/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repository;
  SettingsCubit(this._repository) : super(SettingsState.initial());

  Future<void> loadSettings() async {
    try {
      emit(state.copyWith(isLoading: true));
      final settings = await _repository.getSettings();
      emit(
        state.copyWith(
          language: settings.language,
          themeMode: settings.themeMode,
          fontSize: settings.fontSize,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  // Đổi ngôn ngữ
  Future<void> changeLanguage(AppLanguage language) async {
    final updated = state.copyWith(language: language);
    emit(updated);
    await _repository.saveLanguage(language);
  }

  // Đổi theme
  Future<void> changeThemeMode(AppThemeMode themeMode) async {
    final updated = state.copyWith(themeMode: themeMode);
    emit(updated);
    await _repository.saveThemeMode(themeMode);
  }

  // Đổi font size
  Future<void> changeFontSize(AppFontSize fontSize) async {
    final updated = state.copyWith(fontSize: fontSize);
    emit(updated);
    await _repository.saveFontSize(fontSize);
  }
}