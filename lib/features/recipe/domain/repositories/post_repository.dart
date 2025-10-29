import '../../data/models/post_model.dart';

abstract class PostRepository {
  Future<PostModel> createPost(int recipeId, String content);
  Future<PostModel> updatePost(int id, String content);
  Future<void> deletePost(int id);
}
