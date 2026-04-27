import '../../data/models/post_publish_model.dart';
import '../../data/models/similar_post_model.dart';

abstract class PostPublishRepository {
  Future<PostPublishModel> createPost(int recipeId, String content);
  Future<PostPublishModel> updatePost(int id, String content);
  Future<void> deletePost(int id);

  Future<List<PostPublishModel>> getPublishedPosts();
  Future<List<SimilarPostModel>> getSimilarRecipes(
    int recipeId, {
    List<String>? ingredients,
    int limit = 10,
  });
}
