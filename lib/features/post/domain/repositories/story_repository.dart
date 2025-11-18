import 'package:eefood/features/post/data/models/user_story_model.dart';

abstract class StoryRepository {
  Future<UserStoryModel> getOwnStory();
  Future<List<UserStoryModel>> getFeed(int viewerId);
  Future<void> markViewStory(int storyId, int viewerId);
}
