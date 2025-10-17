class CommentModel {
  final int? id;
  final int? userId;
  final int? parentId;
  final String content;
  final DateTime? createdAt;
  final List<CommentModel>? replies;
  final Map<String, int>? reactionCounts;
  final int? replyCount;
  final List<String>? images;
  final List<String>? videos;
  final String? username;
  final String? email;
  final String? avatarUrl;
  final int level;
  final bool isRepliesExpanded;

  CommentModel({
    this.id,
    this.parentId,
    this.userId,
    required this.content,
    this.createdAt,
    this.replies,
    this.reactionCounts,
    this.replyCount,
    this.images,
    this.videos,
    this.username,
    this.email,
    this.avatarUrl,
    this.level = 0,
    this.isRepliesExpanded = false,
  });

  factory CommentModel.fromJson(
    Map<String, dynamic> json, {
    int level = 0,
    bool isRepliesExpanded = false,
  }) {
    List<CommentModel>? replies;
    if (json['replies'] != null) {
      replies = (json['replies'] as List)
          .map((reply) => CommentModel.fromJson(reply, level: level + 1))
          .toList();
    }
    return CommentModel(
      id: json['id'],
      parentId: json['parentId'] ?? null,
      userId: json['userId'],
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      replies: replies,
      reactionCounts: Map<String, int>.from(json['reactionCounts'] ?? {}),
      replyCount: json['replyCount'] ?? 0,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((img) => img as String)
              .toList() ??
          [],
      videos:
          (json['videos'] as List<dynamic>?)
              ?.map((vid) => vid as String)
              .toList() ??
          [],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      level: level,
      isRepliesExpanded: isRepliesExpanded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentId': parentId,
      'userId': userId,
      'content': content,
      'createdAt': createdAt?.toIso8601String(),
      'replies': replies?.map((reply) => reply.toJson()).toList(),
      'reactionCounts': reactionCounts,
      'replyCount': replyCount,
      'images': images,
      'videos': videos,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
    };
  }
}
