import 'package:eefood/features/livestream/data/model/live_subtitle_message.dart';
import 'package:eefood/features/livestream/domain/enum/subtitle_language.dart';

class SubtitleState {
  final SubtitleLanguage selectedSubtitleLanguage;
  final LiveSubtitleMessage? latestSubtitle;
  final bool isSubtitleConnected;
  final String? subtitleError;

  const SubtitleState({
    this.selectedSubtitleLanguage = SubtitleLanguage.vi,
    this.latestSubtitle,
    this.isSubtitleConnected = false,
    this.subtitleError,
  });

  SubtitleState copyWith({
    SubtitleLanguage? selectedSubtitleLanguage,
    LiveSubtitleMessage? latestSubtitle,
    bool? isSubtitleConnected,
    String? subtitleError,
    bool clearLatestSubtitle = false,
    bool clearSubtitleError = false,
  }) {
    return SubtitleState(
      selectedSubtitleLanguage:
          selectedSubtitleLanguage ?? this.selectedSubtitleLanguage,
      latestSubtitle: clearLatestSubtitle
          ? null
          : (latestSubtitle ?? this.latestSubtitle),
      isSubtitleConnected: isSubtitleConnected ?? this.isSubtitleConnected,
      subtitleError: clearSubtitleError
          ? null
          : (subtitleError ?? this.subtitleError),
    );
  }
}
