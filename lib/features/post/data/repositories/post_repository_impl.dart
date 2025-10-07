
import 'package:dio/dio.dart';
import 'package:eefood/features/post/domain/repositories/post_repository.dart';

import '../models/post_model.dart';

class PostRepositoryImpl extends PostRepository{
  final Dio dio;
  PostRepositoryImpl({required this.dio});
  @override
  Future<List<PostModel>> getAllPosts(int page, int size) async{
    final response = await dio.get(
      '/v1/posts',
      queryParameters: {
        'page': page,
        'size': size,
      }
    );

    final data = response.data['data']['content'] as List<dynamic>;
    return data.map((e) => PostModel.fromJson(e)).toList();
  }

  @override
  Future<PostModel> getPostById(int id) async{
    final response = await dio.get('/v1/posts/$id');
    return PostModel.fromJson(response.data['data']);
  }
}