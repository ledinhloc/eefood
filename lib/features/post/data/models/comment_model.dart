class CommentModel {
  final int id;
  final int userId;
  final String content;
  final DateTime createdAt;
  final List<CommentModel> replies;
  final Map<String, int> reactionCounts;

  CommentModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.replies,
    required this.reactionCounts,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      userId: json['userId'],
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      replies: (json['replies'] as List<dynamic>?)
          ?.map((r) => CommentModel.fromJson(r))
          .toList() ??
          [],
      reactionCounts: Map<String, int>.from(json['reactionCounts'] ?? {}),
    );
  }
}
