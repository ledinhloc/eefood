import 'package:eefood/features/post/data/models/reaction_type.dart';

class StoryReactionModel {
  final int? id;
  final int storyId;
  final int userId;
  final String? username;
  final String? avatarUrl;
  final ReactionType reactionType;
  final DateTime createdAt;

  StoryReactionModel({
    this.id,
    required this.storyId,
    required this.userId,
    this.username,
    this.avatarUrl,
    required this.reactionType,
    required this.createdAt,
  });

  factory StoryReactionModel.fromJson(Map<String, dynamic> json) {
    return StoryReactionModel(
      id: json['id'],
      storyId: json['storyId'],
      userId: json['userId'],
      username: json['username'],
      avatarUrl: json['avatarUrl'],
      reactionType: ReactionType.values.byName(json['reactionType']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'storyId': storyId,
    'userId': userId,
    'username': username,
    'avatarUrl': avatarUrl,
    'reactionType': reactionType.name,
    'createdAt': createdAt.toIso8601String(),
  };
}

class StoryReactionPage {
  final List<StoryReactionModel> reactions;
  final int totalElements;
  final int numberOfElements;

  StoryReactionPage({
    required this.reactions,
    required this.totalElements,
    required this.numberOfElements,
  });

  factory StoryReactionPage.fromJson(Map<String, dynamic> json) {
    return StoryReactionPage(
      numberOfElements: json['numberOfElements'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      reactions: (json['content'] as List<dynamic>? ?? [])
          .map((e) => StoryReactionModel.fromJson(e))
          .toList(),
    );
  }
}
