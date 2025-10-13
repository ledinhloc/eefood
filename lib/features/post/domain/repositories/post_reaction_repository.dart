
import 'package:eefood/features/post/data/models/reaction_type.dart';

import '../../data/models/post_reaction_model.dart';

abstract class PostReactionRepository{
  Future<PostReactionModel?> reactToPost(int postId, ReactionType type);
  Future<void> removeReaction(int postId);
  Future<List<PostReactionModel>> getReactionByPosts(int postId);
}