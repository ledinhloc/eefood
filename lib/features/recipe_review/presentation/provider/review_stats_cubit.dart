import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eefood/features/recipe_review/data/models/recipe_review_stats_model.dart';
import 'package:eefood/features/recipe_review/domain/repositories/review_recipe_repository.dart';

enum ReviewStatsStatus { initial, loading, success, failure }

class ReviewStatsState {
  final ReviewStatsStatus status;
  final RecipeReviewStatsModel? stats;
  final String? error;

  const ReviewStatsState({
    this.status = ReviewStatsStatus.initial,
    this.stats,
    this.error,
  });

  ReviewStatsState copyWith({
    ReviewStatsStatus? status,
    RecipeReviewStatsModel? stats,
    String? error,
  }) {
    return ReviewStatsState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      error: error ?? this.error,
    );
  }

  bool get isLoading => status == ReviewStatsStatus.loading;
  bool get isSuccess => status == ReviewStatsStatus.success;
  bool get isFailure => status == ReviewStatsStatus.failure;
}

class ReviewStatsCubit extends Cubit<ReviewStatsState> {
  final ReviewRecipeRepository _repository;

  ReviewStatsCubit({required ReviewRecipeRepository repository})
    : _repository = repository,
      super(const ReviewStatsState());

  Future<void> loadStats(int recipeId) async {
    emit(state.copyWith(status: ReviewStatsStatus.loading));
    try {
      final stats = await _repository.getRecipeReviewStats(recipeId);
      emit(state.copyWith(status: ReviewStatsStatus.success, stats: stats));
    } catch (e) {
      emit(
        state.copyWith(status: ReviewStatsStatus.failure, error: e.toString()),
      );
    }
  }
}
