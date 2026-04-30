import 'package:dio/dio.dart';
import 'package:eefood/core/utils/logger.dart';
import 'package:eefood/features/recipe_review/data/models/recipe_review_request.dart';
import 'package:eefood/features/recipe_review/data/models/recipe_review_stats_model.dart';
import 'package:eefood/features/recipe_review/data/models/review_detail_model.dart';
import 'package:eefood/features/recipe_review/data/models/review_question_model.dart';
import 'package:eefood/features/recipe_review/domain/repositories/review_recipe_repository.dart';

class ReviewRecipeRepositoryImpl extends ReviewRecipeRepository {
  final Dio dio;

  ReviewRecipeRepositoryImpl({required this.dio});

  @override
  Future<List<ReviewDetailModel>> getRecipeReviews(
    int recipeId, {
    int? page = 1,
    int? size = 10,
  }) async {
    try {
      final response = await dio.get(
        '/v1/recipe-review/$recipeId/list',
        queryParameters: {'page': page, 'size': size},
      );
      if (response.statusCode == 200) {
        final data = response.data['data'];
        final content = data['content'] as List<dynamic>;
        return content.map((json) => ReviewDetailModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get review');
      }
    } catch (err) {
      logger.e('Error: $err');
      throw Exception('Failed to get review $err');
    }
  }

  @override
  Future<RecipeReviewStatsModel?> getRecipeReviewStats(int recipeId) async {
    try {
      final response = await dio.get('/v1/recipe-review/$recipeId/stats');
      final json = response.data;
      if (json != null && json['data'] != null) {
        return RecipeReviewStatsModel.fromJson(json['data']);
      }
      return null;
    } catch (err) {
      logger.i('Error: $err');
      throw Exception('Failed to get review stats $err');
    }
  }

  @override
  Future<List<ReviewQuestionModel>> getListReviewQuestion() async {
    try {
      final response = await dio.get('/v1/recipe-review');
      final json = response.data;
      if (json != null && json['data'] != null) {
        final List<dynamic> data = json['data'] as List<dynamic>;

        return List<ReviewQuestionModel>.from(
          data.map((e) => ReviewQuestionModel.fromJson(e)),
        );
      }
      return List.empty();
    } catch (err) {
      logger.i('Error: $err');
      throw Exception('Failed to get list question $err');
    }
  }

  @override
  Future<void> saveUserReview(
    int recipeId,
    List<RecipeReviewRequest> request,
  ) async {
    try {
      final response = await dio.post(
        '/v1/recipe-review/$recipeId',
        data: request.map((e) => e.toJson()).toList(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to save user review');
      }
    } catch (err) {
      throw Exception('Failed to save user review');
    }
  }
}
