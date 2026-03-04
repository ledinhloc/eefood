import 'package:flutter/material.dart';

export 'package:eefood/features/app_settings/collections/app_settings.dart';

import 'package:eefood/features/app_settings/collections/app_settings.dart';

class SettingsState {
  final AppLanguage language;
  final AppThemeMode themeMode;
  final AppFontSize fontSize;
  final bool isLoading;

  const SettingsState({
    required this.language,
    required this.themeMode,
    required this.fontSize,
    this.isLoading = false,
  });

  factory SettingsState.initial() => const SettingsState(
    language: AppLanguage.vi,
    themeMode: AppThemeMode.system,
    fontSize: AppFontSize.small,
  );

  SettingsState copyWith({
    AppLanguage? language,
    AppThemeMode? themeMode,
    AppFontSize? fontSize,
    bool? isLoading,
  }) {
    return SettingsState(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Chuyển AppThemeMode → Flutter ThemeMode
  ThemeMode get flutterThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// Chuyển AppLanguage → Locale
  Locale get locale {
    switch (language) {
      case AppLanguage.vi:
        return const Locale('vi');
      case AppLanguage.en:
        return const Locale('en');
    }
  }

  /// Scale factor cho TextTheme dựa vào fontSize enum
  double get textScaleFactor {
    switch (fontSize) {
      case AppFontSize.small:
        return 0.75;
      case AppFontSize.medium:
        return 1.0;
      case AppFontSize.large:
        return 1.15;
      case AppFontSize.extraLarge:
        return 1.3;
    }
  }
}
