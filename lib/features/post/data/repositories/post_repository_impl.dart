import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eefood/features/post/domain/repositories/post_repository.dart';
import 'package:http_parser/http_parser.dart';

import '../models/post_model.dart';

class PostRepositoryImpl extends PostRepository{
  final Dio dio;
  PostRepositoryImpl({required this.dio});

  @override
  Future<String> getKeywordFromImage(File imageFile) async {
    final String fileName = imageFile.path.split('/').last;

    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
        contentType: MediaType('image', 'jpeg'),
      ),
    });

    final response = await dio.post(
      '/v1/posts/get-keyword',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        sendTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
      ),
    );

    if (response.statusCode == 200) {
      return response.data['data'] as String;
    } else {
      throw Exception('Failed to get keyword from image');
    }
  }

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
  Future<List<PostModel>> getOwnPosts(
    int page,
    int size,
    int userId, {
    String? sortBy,
  }) async {
    final response = await dio.get(
      '/v1/posts/my',
      queryParameters: {
        'userId': userId,
        'page': page,
        'size': size,
        if (sortBy != null) 'sortBy': sortBy,
      },
    );
    print('OwnPosts Response data: ${response.data}'); // Debug full data
    if (response.statusCode == 200) {
      final data = response.data['data'];
      final content = data['content'] as List<dynamic>;
      print('OwnPosts Content length: ${content.length}');
      return content.map((json) => PostModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<int> getOwnPostsCount(int userId) async {
    final response = await dio.get(
      '/v1/posts/my',
      queryParameters: {
        'userId': userId,
        'page': 1,
        'size': 1,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return data['totalElements'] ?? 0;
    } else {
      throw Exception('Failed to load post count');
    }
  }

  @override
  Future<PostModel> getPostById(int id) async {
    final response = await dio.get('/v1/posts/$id');
    return PostModel.fromJson(response.data['data']);
  }
}
