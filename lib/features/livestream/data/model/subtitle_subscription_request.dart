import '../../domain/enum/subtitle_language.dart';

class SubtitleSubscriptionRequest {
  final int liveStreamId;
  final SubtitleLanguage targetLanguage;

  const SubtitleSubscriptionRequest({
    required this.liveStreamId,
    required this.targetLanguage,
  });

  Map<String, dynamic> toJson() {
    return {
      'liveStreamId': liveStreamId,
      'targetLanguage': targetLanguage.code,
    };
  }
}
