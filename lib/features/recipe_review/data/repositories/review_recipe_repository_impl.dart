import 'package:dio/dio.dart';
import 'package:eefood/core/utils/logger.dart';
import 'package:eefood/features/recipe_review/data/models/recipe_review_request.dart';
import 'package:eefood/features/recipe_review/data/models/review_question_model.dart';

class ReviewRecipeRepositoryImpl {
  final Dio dio;

  ReviewRecipeRepositoryImpl({required this.dio});

  @override
  Future<List<ReviewQuestionModel>> getListReviewQuestion() async {
    try {
      final response = await dio.get('/v1/recipe-review');
      final json = response.data;
      if (json != null && json['data'] != null) {
        final data = json['data'];
        return data
            .map((e) => ReviewQuestionModel.fromJson(e as Map<String, dynamic>))
            .toList();
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
        data: {'request': request.map((e) => e.toJson()).toList()},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to save user review');
      }
    } catch (err) {
      throw Exception('Failed to save user review');
    }
  }
}
