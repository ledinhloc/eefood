class LiveStreamResponse {
  final int id;
  final int userId;
  final String roomName;
  final String title;
  final String? thumbnailUrl;
  final String? livekitToken;
  final String? livekitRoomSid;
  final String status;
  final int viewerCount;

  LiveStreamResponse({
    required this.id,
    required this.userId,
    required this.roomName,
    required this.title,
    this.thumbnailUrl,
    this.livekitToken,
    this.livekitRoomSid,
    required this.status,
    required this.viewerCount,
  });

  factory LiveStreamResponse.fromJson(Map<String, dynamic> json) {
    return LiveStreamResponse(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      roomName: json['roomName'] as String,
      title: json['title'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      livekitToken: json['livekitToken'] as String?,
      livekitRoomSid: json['livekitRoomSid'] as String?,
      status: json['status'] as String,
      viewerCount: (json['viewerCount'] as num?)?.toInt() ?? 0,
    );
  }
}
