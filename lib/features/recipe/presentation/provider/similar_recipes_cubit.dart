import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../data/models/similar_post_model.dart';
import '../../domain/repositories/post_publish_repository.dart';

class SimilarRecipesState {
  final bool isLoading;
  final List<SimilarPostModel> recipes;
  final String? error;

  const SimilarRecipesState({
    this.isLoading = false,
    this.recipes = const [],
    this.error,
  });

  SimilarRecipesState copyWith({
    bool? isLoading,
    List<SimilarPostModel>? recipes,
    String? error,
  }) {
    return SimilarRecipesState(
      isLoading: isLoading ?? this.isLoading,
      recipes: recipes ?? this.recipes,
      error: error,
    );
  }
}

class SimilarRecipesCubit extends Cubit<SimilarRecipesState> {
  final PostPublishRepository _repository = getIt<PostPublishRepository>();

  SimilarRecipesCubit() : super(const SimilarRecipesState());

  Future<void> loadSimilarRecipes(
    int recipeId, {
    List<String>? ingredients,
    int limit = 10,
  }) async {
    emit(const SimilarRecipesState(isLoading: true));

    try {
      final recipes = await _repository.getSimilarRecipes(
        recipeId,
        ingredients: ingredients,
        limit: limit,
      );
      emit(SimilarRecipesState(recipes: recipes));
    } catch (e) {
      emit(SimilarRecipesState(error: e.toString()));
    }
  }
}
