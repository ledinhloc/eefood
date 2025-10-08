
import '../../data/models/post_model.dart';

abstract class PostRepository{
  Future<List<PostModel>> getAllPosts(int page, int size);
  Future<PostModel> getPostById(int id);
}