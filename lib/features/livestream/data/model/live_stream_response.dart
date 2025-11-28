enum LiveStreamStatus { SCHEDULED, LIVE, ENDED, CANCELLED }

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

  factory LiveStreamResponse.fromJson(Map<String, dynamic> json) {
    LiveStreamStatus parseStatus(String s) {
      switch (s) {
        case 'SCHEDULED':
          return LiveStreamStatus.SCHEDULED;
        case 'LIVE':
          return LiveStreamStatus.LIVE;
        case 'ENDED':
          return LiveStreamStatus.ENDED;
        case 'CANCELLED':
          return LiveStreamStatus.CANCELLED;
        default:
          return LiveStreamStatus.SCHEDULED; // fallback
      }
    }

    DateTime? parseDateTime(String? s) =>
        s != null ? DateTime.parse(s) : null;

    return LiveStreamResponse(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      roomName: json['roomName'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      status: parseStatus(json['status'] as String),
      viewerCount: (json['viewerCount'] as num?)?.toInt() ?? 0,
      scheduledAt: parseDateTime(json['scheduledAt'] as String?),
      startedAt: parseDateTime(json['startedAt'] as String?),
      endedAt: parseDateTime(json['endedAt'] as String?),
      livekitToken: json['livekitToken'] as String?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
