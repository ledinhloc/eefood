import 'package:eefood/core/database/base_local_data_source.dart';
import 'package:eefood/features/app_settings/collections/app_settings.dart';

class SettingsLocalDataSource extends BaseLocalDataSource {
  Future<AppSettings> getSettings() async {
    final settings = await isar.appSettings.get(1);

    if (settings != null) return settings;

    final defaultSettings = AppSettings()
      ..language = AppLanguage.vi
      ..themeMode = AppThemeMode.system
      ..fontSize = AppFontSize.medium;

    await isar.writeTxn(() async {
      await isar.appSettings.put(defaultSettings);
    });

    return defaultSettings;
  }

  Future<void> saveSettings(AppSettings settings) async {
    await isar.writeTxn(() async {
      await isar.appSettings.put(settings);
    });
  }
}
