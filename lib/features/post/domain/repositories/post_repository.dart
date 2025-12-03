import 'dart:io';

import 'package:eefood/features/post/data/models/story_collection_model.dart';
import 'package:eefood/features/post/data/models/story_model.dart';

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
  Future<List<PostModel>> getOwnPosts(
    int page,
    int size,
    int userId, {
    String? sortBy,
  });
  Future<PostModel> getPostById(int id);
}
