class StoryCommentModel {
  final int? id;
  final int storyId;
  final int userId;
  final String message;
  final int? parentId;
  final String? username;
  final String? email;
  final String? avatarUrl;
  final DateTime? createdAt;
  StoryCommentModel({
    this.id,
    required this.storyId,
    required this.userId,
    required this.message,
    this.parentId,
    this.username,
    this.email,
    this.avatarUrl,
    this.createdAt,
  });

  factory StoryCommentModel.fromJson(Map<String, dynamic> json) {
    return StoryCommentModel(
      id: json['id'],
      userId: json['userId'],
      storyId: json['storyId'],
      parentId: json['parentId'],
      message: json['message'],
      username: json['username'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  StoryCommentModel copyWith({
    int? id,
    int? userId,
    String? type,
    String? contentUrl,
    DateTime? createdAt,
    DateTime? expiredAt,
    String? username,
    String? email,
    String? avatarUrl,
    bool? isViewed,
  }) {
    return StoryCommentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      storyId: storyId ?? this.storyId,
      parentId: parentId ?? this.parentId,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
class StoryCommentPage {
  final int totalElements;
  final int numberOfElements;
  final List<StoryCommentModel> viewers;

  StoryCommentPage({
    required this.totalElements,
    required this.numberOfElements,
    required this.viewers,
  });

  factory StoryCommentPage.fromJson(Map<String, dynamic> json) {
    return StoryCommentPage(
      numberOfElements: json['numberOfElements'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      viewers: (json['content'] as List<dynamic>? ?? [])
          .map((e) => StoryCommentModel.fromJson(e))
          .toList(),
    );
  }
}
