import 'package:eefood/features/recipe_review/data/models/recipe_review_request.dart';
import 'package:eefood/features/recipe_review/data/models/review_question_model.dart';

abstract class ReviewRecipeRepository {
  Future<List<ReviewQuestionModel>> getListReviewQuestion();
  Future<void> saveUserReview(int recipeId, List<RecipeReviewRequest> request);
}
