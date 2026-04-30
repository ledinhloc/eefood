import 'package:eefood/features/recipe_review/data/models/recipe_review_request.dart';
import 'package:eefood/features/recipe_review/data/models/review_option_model.dart';
import 'package:eefood/features/recipe_review/data/models/review_question_model.dart';
import 'package:eefood/features/recipe_review/domain/repositories/review_recipe_repository.dart';
import 'package:eefood/features/recipe_review/presentation/provider/review_recipe_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReviewRecipeCubit extends Cubit<RecipeReviewState> {
  final ReviewRecipeRepository repository;

  ReviewRecipeCubit({required this.repository})
    : super(const RecipeReviewState());

  void _safeEmit(RecipeReviewState state) {
    if (!isClosed) {
      emit(state);
    }
  }

  Future<void> loadQuestions() async {
    _safeEmit(const RecipeReviewState(status: RecipeReviewStatus.loading));
    try {
      final questions = await repository.getListReviewQuestion();
      _safeEmit(
        state.copyWith(status: RecipeReviewStatus.loaded, questions: questions),
      );
    } catch (e) {
      _safeEmit(
        state.copyWith(status: RecipeReviewStatus.error, error: e.toString()),
      );
    }
  }

  void selectOption(int questionId, int optionId) {
    final updated = Map<int, int>.from(state.selectedOptions);
    updated[questionId] = optionId;
    _safeEmit(state.copyWith(selectedOptions: updated));
  }

  Future<void> submitReview(int recipeId) async {
    _safeEmit(state.copyWith(status: RecipeReviewStatus.submitting));
    try {
      final requests = state.selectedOptions.entries.map((e) {
        final question = state.questions.firstWhere(
          (q) => q.id == e.key,
          orElse: () => ReviewQuestionModel(),
        );
        final option = question.options?.firstWhere(
          (o) => o.id == e.value,
          orElse: () => ReviewOptionModel(),
        );
        return RecipeReviewRequest(
          questionId: e.key,
          optionId: e.value,
          starValue: option?.starValue,
        );
      }).toList();

      await repository.saveUserReview(recipeId, requests);
      _safeEmit(state.copyWith(status: RecipeReviewStatus.success));
    } catch (e) {
      _safeEmit(
        state.copyWith(
          status: RecipeReviewStatus.error,
          error: 'Không thể gửi đánh giá. Vui lòng thử lại.',
        ),
      );
    }
  }
}
