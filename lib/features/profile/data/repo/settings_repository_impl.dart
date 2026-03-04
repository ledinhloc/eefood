import 'package:eefood/features/app_settings/collections/app_settings.dart';
import 'package:eefood/features/app_settings/data_sources/settings_local_data_source.dart';
import 'package:eefood/features/profile/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl extends SettingsRepository {
  final SettingsLocalDataSource _dataSource;
  SettingsRepositoryImpl(this._dataSource);

  @override
  Future<AppSettings> getSettings() => _dataSource.getSettings();

  @override
  Future<void> saveLanguage(AppLanguage language) async {
    final current = await _dataSource.getSettings();
    current.language = language;
    await _dataSource.saveSettings(current);
  }

  @override
  Future<void> saveThemeMode(AppThemeMode themeMode) async {
    final current = await _dataSource.getSettings();
    current.themeMode = themeMode;
    await _dataSource.saveSettings(current);
  }

  @override
  Future<void> saveFontSize(AppFontSize fontSize) async {
    final current = await _dataSource.getSettings();
    current.fontSize = fontSize;
    await _dataSource.saveSettings(current);
  }
}
