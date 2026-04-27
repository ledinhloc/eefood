import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../data/models/similar_post_model.dart';
import '../../domain/repositories/post_publish_repository.dart';

class SimilarRecipesState {
  final bool isLoading;
  final List<SimilarPostModel> recipes;
  final Set<String> selectedIngredients;
  final String? error;

  const SimilarRecipesState({
    this.isLoading = false,
    this.recipes = const [],
    this.selectedIngredients = const {},
    this.error,
  });

  SimilarRecipesState copyWith({
    bool? isLoading,
    List<SimilarPostModel>? recipes,
    Set<String>? selectedIngredients,
    String? error,
  }) {
    return SimilarRecipesState(
      isLoading: isLoading ?? this.isLoading,
      recipes: recipes ?? this.recipes,
      selectedIngredients: selectedIngredients ?? this.selectedIngredients,
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
    final selectedIngredients = ingredients == null
        ? state.selectedIngredients
        : ingredients.toSet();

    emit(
      state.copyWith(isLoading: true, selectedIngredients: selectedIngredients),
    );

    try {
      final recipes = await _repository.getSimilarRecipes(
        recipeId,
        ingredients: selectedIngredients.isEmpty
            ? null
            : selectedIngredients.toList(),
        limit: limit,
      );
      emit(
        state.copyWith(
          isLoading: false,
          recipes: recipes,
          selectedIngredients: selectedIngredients,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          selectedIngredients: selectedIngredients,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> toggleIngredient(int recipeId, String ingredient) {
    final selectedIngredients = Set<String>.from(state.selectedIngredients);

    if (selectedIngredients.contains(ingredient)) {
      selectedIngredients.remove(ingredient);
    } else {
      selectedIngredients.add(ingredient);
    }

    return loadSimilarRecipes(
      recipeId,
      ingredients: selectedIngredients.toList(),
    );
  }

  Future<void> clearIngredients(int recipeId) {
    if (state.selectedIngredients.isEmpty) {
      return Future.value();
    }

    return loadSimilarRecipes(recipeId, ingredients: const []);
  }
}
