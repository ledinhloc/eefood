import 'package:eefood/features/post/data/models/story_collection_model.dart';
import 'package:eefood/features/post/data/models/story_model.dart';

abstract class StoryCollectionRepository {
  Future<StoryCollectionModel> createStoryCollection(
    StoryCollectionModel request,
  );
  Future<StoryCollectionModel> updateStoryCollection(
    StoryCollectionModel request,
    int id,
  );
  Future<void> deleteStoryCollection(int id);
    Future<StoryCollectionPageModel> getUserCollections(
    int userId, {
    int page = 1,
    int limit = 5,
  });
  Future<List<StoryModel>> getAllStoryCollections(int collectionId);
  Future<void> addStoryToCollection(int collectionId, int storyId);
  Future<void> removeStoryToCollection(int collectionId, int storyId);
}
