import 'package:eefood/features/post/data/models/reaction_type.dart';

class CommentReactionModel {
  final int commentId;
  final int userId;
  final ReactionType reactionType;
  final DateTime createdAt;

  CommentReactionModel({
    required this.commentId,
    required this.userId,
    required this.reactionType,
    required this.createdAt
  });

  factory CommentReactionModel.fromJson(Map<String, dynamic> json) {
    return CommentReactionModel(
      commentId: json['commentId'], 
      userId: json['userId'], 
      reactionType: ReactionType.values.byName(json['reactionType']), 
      createdAt: DateTime.parse(json['createdAt'])
    );
  }

  Map<String, dynamic> toJson() => {
    'commentId': commentId,
    'userId': userId,
    'reactionType': reactionType.name,
    'createdAt': createdAt.toIso8601String(),
  };
}