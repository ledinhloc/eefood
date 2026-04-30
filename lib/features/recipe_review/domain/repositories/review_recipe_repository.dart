import 'package:eefood/features/recipe_review/data/models/recipe_review_request.dart';
import 'package:eefood/features/recipe_review/data/models/recipe_review_stats_model.dart';
import 'package:eefood/features/recipe_review/data/models/review_detail_model.dart';
import 'package:eefood/features/recipe_review/data/models/review_question_model.dart';

abstract class ReviewRecipeRepository {
  Future<List<ReviewDetailModel>> getRecipeReviews(
    int recipeId, {
    int? page = 1,
    int? size = 10,
  });
  Future<RecipeReviewStatsModel?> getRecipeReviewStats(int recipeId);
  Future<List<ReviewQuestionModel>> getListReviewQuestion();
  Future<void> saveUserReview(int recipeId, List<RecipeReviewRequest> request);
}
