import 'package:eefood/core/di/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/recipe_detail_model.dart';
import '../../domain/repositories/recipe_repository.dart';

class RecipeDetailState {
  final bool isLoading;
  final RecipeDetailModel? recipe;
  final String? error;

  const RecipeDetailState({
    this.isLoading = false,
    this.recipe,
    this.error,
  });

  RecipeDetailState copyWith({
    bool? isLoading,
    RecipeDetailModel? recipe,
    String? error,
  }) {
    return RecipeDetailState(
      isLoading: isLoading ?? this.isLoading,
      recipe: recipe ?? this.recipe,
      error: error ?? this.error,
    );
  }
}

class RecipeDetailCubit extends Cubit<RecipeDetailState> {
  final RecipeRepository repository = getIt<RecipeRepository>();
  RecipeDetailCubit() : super(const RecipeDetailState());

  Future<void> loadRecipe(int recipeId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final recipe = await repository.fetchRecipeDetail(recipeId);
      emit(state.copyWith(isLoading: false, recipe: recipe));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
