import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:eefood/features/post/data/models/story_reaction_model.dart';

abstract class StoryReactionRepository {
  Future<StoryReactionModel?> getCurrentUserReaction(int storyId);
  Future<StoryReactionModel?> reactToStory(int storyId, ReactionType type);
  Future<void> removeReaction(int storyId);
  Future<StoryReactionPage> getUserReactedStory(
    int storyId, {
    int page = 1,
    int limit = 5,
  });
}
