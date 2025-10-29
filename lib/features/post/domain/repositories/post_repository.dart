
import '../../data/models/post_model.dart';

abstract class PostRepository{
  Future<List<PostModel>> getAllPosts(int page, int size, {
    String? keyword,
    int? userId,
    String? region,
    String? difficulty,
  });
  Future<PostModel> getPostById(int id);
}