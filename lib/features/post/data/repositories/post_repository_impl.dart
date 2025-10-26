
import 'package:dio/dio.dart';
import 'package:eefood/features/post/domain/repositories/post_repository.dart';

import '../models/post_model.dart';

class PostRepositoryImpl extends PostRepository{
  final Dio dio;
  PostRepositoryImpl({required this.dio});

  @override
  Future<List<PostModel>> getAllPosts(int page, int size, {
    String? keyword,
    int? userId,
    String? region,
    String? difficulty,
  }) async{
    final response = await dio.get(
      '/v1/posts',
      queryParameters: {
        'page': page,
        'size': size,
        if (keyword != null) 'keyword': keyword,
        if (userId != null) 'userId': userId,
        if (region != null) 'region': region,
        if (difficulty != null) 'difficulty': difficulty,
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