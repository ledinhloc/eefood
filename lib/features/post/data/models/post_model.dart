import 'package:eefood/features/post/data/models/reaction_type.dart';

import 'comment_model.dart';

class PostModel{
  final int id;
  final int userId;
  final String username;
  final String email;
  final String avatarUrl;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int totalFavorites;
  final int totalShares;
  final Map<ReactionType, int> reactionCounts;
  final List<CommentModel> comments;

  // ====== Thêm các field  từ recipe ======
  final int recipeId;
  final String title;
  final String imageUrl;
  final String? description;
  final String? region;
  final int? prepTime;
  final int? cookTime;
  final String? difficulty;
  final List<String> recipeCategories;
  final List<String> recipeIngredientKeywords;

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.email,
    required this.avatarUrl,
    required this.recipeId,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.totalFavorites,
    required this.totalShares,
    required this.reactionCounts,
    required this.comments,
    this.description,
    this.region,
    this.prepTime,
    this.cookTime,
    this.difficulty,
    this.recipeCategories = const [],
    this.recipeIngredientKeywords = const [],
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
      avatarUrl: json['avatarUrl'] ?? '',
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
      description: json['description'],
      region: json['region'],
      prepTime: json['prepTime'],
      cookTime: json['cookTime'],
      difficulty: json['difficulty'],
      recipeCategories: (json['recipeCategories'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      recipeIngredientKeywords: (json['recipeIngredientKeywords'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    );
  }
}