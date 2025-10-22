import 'package:eefood/features/post/data/models/comment_reaction_model.dart';
import 'package:eefood/features/post/data/models/reaction_type.dart';

abstract class CommentReactionRepository {
  Future<CommentReactionModel?> reactToComment(int commentId, ReactionType type);
  Future<void> removeReaction(int commentId);
  Future<List<CommentReactionModel>> getReactionByComment(int commentId);
}