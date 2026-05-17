enum SubtitleLanguage { vi, en }

extension SubtitleLanguageX on SubtitleLanguage {
  String get code => name;

  String get label {
    switch (this) {
      case SubtitleLanguage.vi:
        return 'Tiếng Việt';
      case SubtitleLanguage.en:
        return 'English';
    }
  }
}
