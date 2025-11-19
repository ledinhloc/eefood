import 'package:eefood/features/post/data/models/story_model.dart';
import 'package:eefood/features/post/data/models/user_story_model.dart';

abstract class StoryRepository {
  Future<UserStoryModel> getOwnStory();
  Future<List<UserStoryModel>> getFeed(int viewerId);
  Future<void> markViewStory(int storyId, int viewerId);
  Future<StoryModel> createStory(StoryModel request);
  Future<StoryModel> updateStory(StoryModel request);
  Future<void> deleteStory(int id);
}
