import 'dart:io';

import '../../data/models/post_model.dart';

abstract class PostRepository {
  Future<String> getKeywordFromImage(File imageFile);
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
  });
  Future<PostModel> getPostById(int id);
}
