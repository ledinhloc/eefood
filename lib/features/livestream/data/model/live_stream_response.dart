import 'package:json_annotation/json_annotation.dart';

part 'live_stream_response.g.dart';

// @JsonEnum(alwaysCreate: true)
enum LiveStreamStatus { SCHEDULED, LIVE, ENDED, CANCELLED }

@JsonSerializable()
class LiveStreamResponse {
  final int id;
  final int userId;
  final String roomName;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final LiveStreamStatus status;
  final int viewerCount;
  final DateTime? scheduledAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? livekitToken;
  final String? username;
  final String? email;
  final String? avatarUrl;

  LiveStreamResponse({
    required this.id,
    required this.userId,
    required this.roomName,
    required this.title,
    this.description,
    this.thumbnailUrl,
    required this.status,
    required this.viewerCount,
    this.scheduledAt,
    this.startedAt,
    this.endedAt,
    this.livekitToken,
    this.username,
    this.email,
    this.avatarUrl,
  });

  factory LiveStreamResponse.fromJson(Map<String, dynamic> json) =>
      _$LiveStreamResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LiveStreamResponseToJson(this);
}
