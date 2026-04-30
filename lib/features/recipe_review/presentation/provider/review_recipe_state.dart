import 'package:eefood/features/recipe_review/data/models/review_question_model.dart';

enum RecipeReviewStatus { initial, loading, loaded, submitting, success, error }

class RecipeReviewState {
  final RecipeReviewStatus status;
  final List<ReviewQuestionModel> questions;
  // key: questionId, value: selected optionId
  final Map<int, int> selectedOptions;
  final String? error;

  const RecipeReviewState({
    this.status = RecipeReviewStatus.initial,
    this.questions = const [],
    this.selectedOptions = const {},
    this.error,
  });

  RecipeReviewState copyWith({
    RecipeReviewStatus? status,
    List<ReviewQuestionModel>? questions,
    Map<int, int>? selectedOptions,
    String? error,
  }) {
    return RecipeReviewState(
      status: status ?? this.status,
      questions: questions ?? this.questions,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      error: error ?? this.error,
    );
  }

  bool get isAllAnswered {
    if (questions.isEmpty) return false;
    return questions
        .where((q) => q.id != null)
        .every((q) => selectedOptions.containsKey(q.id));
  }
}
