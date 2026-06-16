import 'dart:io';

import '../../data/models/ingredient_detection_result.dart';
import '../../data/models/post_model.dart';

abstract class PostRepository {
  Future<String> getKeywordFromImage(File imageFile);
  Future<List<String>> detectIngredientLabels(File imageFile);
  Future<IngredientDetectionResult> detectIngredientsWithAnnotatedImage(
    File imageFile,
  );
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

  Future<int> getOwnPostsCount(int userId);
  Future<PostModel> getPostById(int id);
}
