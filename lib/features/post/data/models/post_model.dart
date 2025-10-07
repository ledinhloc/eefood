import 'comment_model.dart';

class PostModel{
  final int id;
  final int userId;
  final int? recipeId;
  final String title;
  final String content;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int totalFavorites;
  final int totalShares;
  final Map<String, int> reactionCounts;
  final List<CommentModel> comments;

  PostModel({
    required this.id,
    required this.userId,
    this.recipeId,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.totalFavorites,
    required this.totalShares,
    required this.reactionCounts,
    required this.comments,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      userId: json['userId'],
      recipeId: json['recipeId'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      totalFavorites: json['totalFavorites'] ?? 0,
      totalShares: json['totalShares'] ?? 0,
      reactionCounts: Map<String, int>.from(json['reactionCounts'] ?? {}),
      comments: (json['comments'] as List<dynamic>?)
          ?.map((c) => CommentModel.fromJson(c))
          .toList() ??
          [],
    );
  }
}