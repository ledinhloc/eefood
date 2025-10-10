import 'package:eefood/features/post/data/models/reaction_type.dart';

import 'comment_model.dart';

class PostModel{
  final int id;
  final int userId;
  final String username;
  final String email;
  final String avatarUrl;
  final int? recipeId;
  final String title;
  final String content;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int totalFavorites;
  final int totalShares;
  final Map<ReactionType, int> reactionCounts;
  final List<CommentModel> comments;

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.email,
    required this.avatarUrl,
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
    final rawReactions = Map<String, dynamic>.from(json['reactionCounts'] ?? {});
    final mappedReactions = <ReactionType, int>{};

    for (final entry in rawReactions.entries) {
      final type = ReactionTypeX.fromString(entry.key);
      if (type != null && entry.value is int) {
        mappedReactions[type] = entry.value;
      }
    }

    return PostModel(
      id: json['id'],
      userId: json['userId'],
      recipeId: json['recipeId'],
      username: json['username'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      totalFavorites: json['totalFavorites'] ?? 0,
      totalShares: json['totalShares'] ?? 0,
      reactionCounts: mappedReactions,
      comments: (json['comments'] as List<dynamic>?)
          ?.map((c) => CommentModel.fromJson(c))
          .toList() ??
          [],
    );
  }
}