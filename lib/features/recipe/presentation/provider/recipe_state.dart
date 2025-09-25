import 'package:eefood/features/recipe/data/models/category_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_Ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';

class RecipeCrudState {
  final RecipeModel recipe;
  final List<RecipeIngredientModel> ingredients;
  final List<RecipeStepModel> steps;
  final List<CategoryModel> categories;

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
      recipe: initialRecipe ?? RecipeModel(id: 0, title: ''),
      ingredients: initialRecipe?.ingredients ?? [],
      steps: initialRecipe?.steps ?? [],
      categories: initialRecipe?.categories ?? [],
      isLoading: false,
      message: null,
    );
  }

  RecipeCrudState copyWith({
    RecipeModel? recipe,
    List<RecipeIngredientModel>? ingredients,
    List<RecipeStepModel>? steps,
    List<CategoryModel>? categories,
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
