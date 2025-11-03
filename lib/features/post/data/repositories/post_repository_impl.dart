
import 'package:dio/dio.dart';
import 'package:eefood/features/post/domain/repositories/post_repository.dart';

import '../models/post_model.dart';

class PostRepositoryImpl extends PostRepository{
  final Dio dio;
  PostRepositoryImpl({required this.dio});

  @override
  Future<List<PostModel>> getAllPosts(
      int page,
      int size, {
        String? keyword,
        int? userId,
        String? region,
        String? difficulty,
        String? category,
        int? maxCookTime,
        String? sortBy,
      }) async {
    final response = await dio.get(
      '/v1/posts',
      queryParameters: {
        'page': page,
        'size': size,
        if (keyword != null) 'keyword': keyword,
        if (userId != null) 'userId': userId,
        if (region != null) 'region': region,
        if (difficulty != null) 'difficulty': difficulty,
        if (category != null) 'category': category,
        if (maxCookTime != null) 'maxCookTime': maxCookTime,
        if (sortBy != null) 'sortBy': sortBy,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      final content = data['content'] as List<dynamic>;
      return content.map((json) => PostModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  @override
  Future<PostModel> getPostById(int id) async{
    final response = await dio.get('/v1/posts/$id');
    return PostModel.fromJson(response.data['data']);
  }
}