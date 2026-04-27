import 'package:dio/dio.dart';
import '../../domain/repositories/post_publish_repository.dart';
import '../models/post_publish_model.dart';
import '../models/similar_post_model.dart';

class PostPublishRepositoryImpl extends PostPublishRepository {
  final Dio dio;

  PostPublishRepositoryImpl({required this.dio});

  @override
  Future<List<PostPublishModel>> getPublishedPosts() async {
    final response = await dio.get('/v1/posts/user');
    final data = response.data['data'] as List;
    return data.map((e) => PostPublishModel.fromJson(e)).toList();
  }

  @override
  Future<List<SimilarPostModel>> getSimilarRecipes(
    int recipeId, {
    List<String>? ingredients,
    int limit = 10,
  }) async {
    final response = await dio.get(
      '/v1/posts/recipes/$recipeId/similar',
      queryParameters: {
        if (ingredients != null && ingredients.isNotEmpty)
          'ingredients': ingredients,
        'limit': limit,
      },
    );
    final data = response.data['data'] as List;
    return data.map((e) => SimilarPostModel.fromJson(e)).toList();
  }

  @override
  Future<PostPublishModel> createPost(int recipeId, String content) async {
    final response = await dio.post(
      '/v1/posts',
      data: {
        'recipeId': recipeId,
        'content': content,
      },
    );
    return PostPublishModel.fromJson(response.data['data']);
  }

  @override
  Future<PostPublishModel> updatePost(int id, String content) async {
    final response = await dio.put(
      '/v1/posts/$id',
      data: {'content': content},
    );
    return PostPublishModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deletePost(int id) async {
    await dio.delete('/v1/posts/$id');
  }
}
