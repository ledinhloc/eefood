import 'package:eefood/features/recipe/data/models/category_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_Ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';

class RecipeCrudState {
  final RecipeModel recipe;
  final List<RecipeIngredientModel> ingredients;
  final List<RecipeStepModel> steps;
  final List<int> categoryIds;

  final bool isLoading;
  final String? message;

  RecipeCrudState({
    required this.recipe,
    required this.ingredients,
    required this.steps,
    required this.categoryIds,
    this.isLoading = false,
    this.message,
  });

  factory RecipeCrudState.initial(RecipeModel? initialRecipe) {
    return RecipeCrudState(
      recipe: initialRecipe ?? RecipeModel(title: ''),
      ingredients: initialRecipe?.ingredients ?? [],
      steps: initialRecipe?.steps ?? [],
      categoryIds: initialRecipe?.categoryIds ?? [],
      isLoading: false,
      message: null,
    );
  }

  RecipeCrudState copyWith({
    RecipeModel? recipe,
    List<RecipeIngredientModel>? ingredients,
    List<RecipeStepModel>? steps,
    List<int>? categoryIds,
    bool? isLoading,
    String? message,
  }) {
    return RecipeCrudState(
      recipe: recipe ?? this.recipe,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      categoryIds: categoryIds ?? this.categoryIds,
      isLoading: isLoading ?? this.isLoading,
      message: message,
    );
  }
}
