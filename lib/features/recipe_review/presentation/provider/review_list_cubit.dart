import 'package:eefood/features/recipe_review/data/models/review_detail_model.dart';
import 'package:eefood/features/recipe_review/domain/repositories/review_recipe_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ReviewListStatus { initial, loadingMore, success, failure }

class ReviewListState {
  final ReviewListStatus status;
  final List<ReviewDetailModel> reviews;
  final bool hasMore;
  final int currentPage;
  final String? error;

  const ReviewListState({
    this.status = ReviewListStatus.initial,
    this.reviews = const [],
    this.hasMore = true,
    this.currentPage = 0,
    this.error,
  });

  ReviewListState copyWith({
    ReviewListStatus? status,
    List<ReviewDetailModel>? reviews,
    bool? hasMore,
    int? currentPage,
    String? error,
  }) => ReviewListState(
    status: status ?? this.status,
    reviews: reviews ?? this.reviews,
    hasMore: hasMore ?? this.hasMore,
    currentPage: currentPage ?? this.currentPage,
    error: error ?? this.error,
  );

  bool get isLoadingMore => status == ReviewListStatus.loadingMore;
}

class ReviewListCubit extends Cubit<ReviewListState> {
  final ReviewRecipeRepository _repository;
  static const int _pageSize = 10;

  ReviewListCubit({required ReviewRecipeRepository repository})
    : _repository = repository,
      super(const ReviewListState());

  Future<void> loadInitial(int recipeId) async {
    emit(
      state.copyWith(
        status: ReviewListStatus.loadingMore,
        reviews: [],
        currentPage: 0,
        hasMore: true,
      ),
    );
    try {
      final reviews = await _repository.getRecipeReviews(
        recipeId,
        page: 1,
        size: _pageSize,
      );
      emit(
        state.copyWith(
          status: ReviewListStatus.success,
          reviews: reviews,
          hasMore: reviews.length >= _pageSize,
          currentPage: 1,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ReviewListStatus.failure, error: e.toString()),
      );
    }
  }

  Future<void> loadMore(int recipeId) async {
    if (state.isLoadingMore || !state.hasMore) return;
    final nextPage = state.currentPage + 1;
    emit(state.copyWith(status: ReviewListStatus.loadingMore));
    try {
      final newReviews = await _repository.getRecipeReviews(
        recipeId,
        page: nextPage,
        size: _pageSize,
      );
      emit(
        state.copyWith(
          status: ReviewListStatus.success,
          reviews: [...state.reviews, ...newReviews],
          hasMore: newReviews.length >= _pageSize,
          currentPage: nextPage,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ReviewListStatus.failure, error: e.toString()),
      );
    }
  }

  Future<void> refresh(int recipeId) => loadInitial(recipeId);
}
