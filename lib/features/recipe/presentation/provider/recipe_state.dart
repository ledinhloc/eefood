import 'package:eefood/features/recipe/data/models/recipe_Ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';

class RecipeCrudState {
  final RecipeModel recipe;
  final List<RecipeIngredientModel> ingredients;
  final List<RecipeStepModel> steps;
  final List<String> categories;
  final bool isLoading;
  final String? message;

  RecipeCrudState({
    required this.recipe,
    required this.ingredients,
    required this.steps,
    required this.categories,
    this.isLoading = false,
    this.message,
  });

  factory RecipeCrudState.initial(RecipeModel? initialRecipe) {
    return RecipeCrudState(
      recipe: initialRecipe ?? RecipeModel(title: ''),
      ingredients: initialRecipe?.ingredients ?? [],
      steps: initialRecipe?.steps ?? [],
      categories: const [],
      isLoading: false,
      message: null,
    );
  }

  RecipeCrudState copyWith({
    RecipeModel? recipe,
    List<RecipeIngredientModel>? ingredients,
    List<RecipeStepModel>? steps,
    List<int>? categoryIds,
    List<String>? categories,
    bool? isLoading,
    String? message,
  }) {
    return RecipeCrudState(
      recipe: recipe ?? this.recipe,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      message: message,
    );
  }
}

class RecipeListState {
  final List<RecipeModel> draftRecipes;
  final List<RecipeModel> publishedRecipes;
  final bool isLoading;
  final String? error;
  final bool hasDraftMore;
  final int draftCurrentPage;

  RecipeListState({
    this.draftRecipes = const [],
    this.publishedRecipes = const [],
    this.isLoading = false,
    this.error,
    this.hasDraftMore = true,
    this.draftCurrentPage = 1,
  });

  RecipeListState copyWith({
    List<RecipeModel>? draftRecipes,
    List<RecipeModel>? publishedRecipes,
    bool? isLoading,
    String? error,
    bool? hasDraftMore,
    int? draftCurrentPage,
  }) {
    return RecipeListState(
      draftRecipes: draftRecipes ?? this.draftRecipes,
      publishedRecipes: publishedRecipes ?? this.publishedRecipes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasDraftMore: hasDraftMore ?? this.hasDraftMore,
      draftCurrentPage: draftCurrentPage ?? this.draftCurrentPage,
    );
  }
}


