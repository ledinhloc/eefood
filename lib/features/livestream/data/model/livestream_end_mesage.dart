class LiveStreamEndMessage {
  final String type;
  final int liveStreamId;
  final String message;
  final DateTime endedAt;
  const LiveStreamEndMessage({
    required this.type,
    required this.liveStreamId,
    required this.message,
    required this.endedAt,
  });

  factory LiveStreamEndMessage.fromJson(Map<String, dynamic> json) {
    return LiveStreamEndMessage(
      type: json['type'] as String,
      liveStreamId: json['liveStreamId'] as int,
      message: json['message'] as String,
      endedAt: DateTime.parse(json['endedAt'] as String),
    );
  }
}