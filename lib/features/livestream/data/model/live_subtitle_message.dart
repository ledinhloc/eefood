import '../../domain/enum/subtitle_language.dart';

class LiveSubtitleMessage {
  final int liveStreamId;
  final SubtitleLanguage targetLanguage;
  final String text;
  final DateTime createdAt;

  const LiveSubtitleMessage({
    required this.liveStreamId,
    required this.targetLanguage,
    required this.text,
    required this.createdAt,
  });

  factory LiveSubtitleMessage.fromJson(Map<String, dynamic> json) {
    return LiveSubtitleMessage(
      liveStreamId: json['liveStreamId'] as int,
      targetLanguage: SubtitleLanguage.values.byName(
        json['targetLanguage'] as String,
      ),
      text: (json['text'] as String?)?.trim() ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
