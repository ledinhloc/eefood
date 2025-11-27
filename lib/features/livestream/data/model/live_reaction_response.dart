class LiveReactionResponse {
  final int id;
  final int liveStreamId;
  final FoodEmotion emotion;
  final int userId;
  final String username;
  final String avatarUrl;
  final DateTime? createdAt;

  LiveReactionResponse({
    required this.id,
    required this.liveStreamId,
    required this.emotion,
    required this.userId,
    required this.username,
    required this.avatarUrl,
    this.createdAt,
  });

  factory LiveReactionResponse.fromJson(Map<String, dynamic> json) {
    return LiveReactionResponse(
      id: json['id'] ?? 0,
      liveStreamId: json['liveStreamId'] ?? 0,
      emotion: parseFoodEmotion(json['emotion'] ?? 'DELICIOUS'),
      userId: json['userId'] ?? 0,
      username: json['username'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}

FoodEmotion parseFoodEmotion(String value) {
  return FoodEmotion.values.firstWhere(
        (e) => e.name == value,
    orElse: () => FoodEmotion.DELICIOUS, // default
  );
}


enum FoodEmotion {
  DELICIOUS,
  LOVE_IT,
  DROOLING,
  BAD,
  NOT_GOOD,
}