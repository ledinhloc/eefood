enum SubtitleLanguage { off, vi, en }

extension SubtitleLanguageX on SubtitleLanguage {
  String get code => name;

  String get label {
    switch (this) {
      case SubtitleLanguage.off:
        return 'Tắt';
      case SubtitleLanguage.vi:
        return 'Tiếng Việt';
      case SubtitleLanguage.en:
        return 'English';
    }
  }

  String get shortLabel {
    switch (this) {
      case SubtitleLanguage.off:
        return 'Tắt';
      case SubtitleLanguage.vi:
        return 'VI';
      case SubtitleLanguage.en:
        return 'EN';
    }
  }
}
