import 'package:eefood/features/recipe/data/models/ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';

class RecipeCrudState {
  final RecipeModel recipe;
  final List<IngredientModel> ingredients;
  final List<RecipeStepModel> steps;

  RecipeCrudState({
    required this.recipe,
    required this.ingredients,
    required this.steps,
  });

  factory RecipeCrudState.initial(RecipeModel? initialRecipe) {
    return RecipeCrudState(
      recipe: initialRecipe ?? RecipeModel(id: 0, title: ''),
      ingredients: initialRecipe?.ingredients ?? [],
      steps: initialRecipe?.steps ?? [],
    );
  }

  RecipeCrudState copyWith({
    RecipeModel? recipe,
    List<IngredientModel>? ingredients,
    List<RecipeStepModel>? steps,
  }) {
    return RecipeCrudState(
      recipe: recipe ?? this.recipe,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
    );
  }

}