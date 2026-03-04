import 'package:isar/isar.dart';

part 'app_settings.g.dart';

@collection
class AppSettings {
  Id id = 1;

  @Enumerated(EnumType.name)
  late AppLanguage language;

  @Enumerated(EnumType.name)
  late AppThemeMode themeMode;

  @Enumerated(EnumType.name)
  late AppFontSize fontSize;
}

enum AppLanguage { vi, en }

enum AppThemeMode { light, dark, system }

enum AppFontSize { small, medium, large, extraLarge }
