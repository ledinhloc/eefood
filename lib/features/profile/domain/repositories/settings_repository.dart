import 'package:eefood/features/app_settings/collections/app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> saveLanguage(AppLanguage language);
  Future<void> saveThemeMode(AppThemeMode themeMode);
  Future<void> saveFontSize(AppFontSize fontSize);
}