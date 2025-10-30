import 'package:dio/dio.dart';
import '../../domain/repositories/post_publish_repository.dart';
import '../models/post_publish_model.dart';

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
