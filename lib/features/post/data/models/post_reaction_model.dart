import 'reaction_type.dart';

class PostReactionModel {
  final int postId;
  final int userId;
  final ReactionType reactionType;
  final DateTime createdAt;

  PostReactionModel({
    required this.postId,
    required this.userId,
    required this.reactionType,
    required this.createdAt,
  });

  factory PostReactionModel.fromJson(Map<String, dynamic> json) {
    return PostReactionModel(
      postId: json['postId'],
      userId: json['userId'],
      reactionType: ReactionType.values.byName(json['reactionType']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'postId': postId,
    'userId': userId,
    'reactionType': reactionType.name,
    'createdAt': createdAt.toIso8601String(),
  };
}
