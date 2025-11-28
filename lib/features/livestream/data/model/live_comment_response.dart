class LiveCommentResponse {
  final int id;
  final int userId;
  final String username;
  final String? avatarUrl;
  final String message;
  final String createdAt;

  LiveCommentResponse({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.message,
    required this.createdAt,
  });

  factory LiveCommentResponse.fromJson(Map<String, dynamic> json) {
    return LiveCommentResponse(
      id: json['id'] as int,
      userId: json['userId'] as int,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      message: json['message'] as String,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'avatarUrl': avatarUrl,
      'message': message,
      'createdAt': createdAt,
    };
  }
}
