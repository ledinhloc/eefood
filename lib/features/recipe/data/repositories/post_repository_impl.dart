import 'package:dio/dio.dart';
import '../../domain/repositories/post_repository.dart';
import '../models/post_model.dart';

class PostRepositoryImpl extends PostRepository {
  final Dio dio;

  PostRepositoryImpl({required this.dio});

  @override
  Future<PostModel> createPost(int recipeId, String content) async {
    final response = await dio.post(
      '/v1/posts',
      data: {
        'recipeId': recipeId,
        'content': content,
      },
    );

    return PostModel.fromJson(response.data['data']);
  }

  @override
  Future<PostModel> updatePost(int id, String content) async {
    final response = await dio.put(
      '/v1/posts/$id',
      data: {'content': content},
    );
    return PostModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deletePost(int id) async {
    await dio.delete('/v1/posts/$id');
  }
}
