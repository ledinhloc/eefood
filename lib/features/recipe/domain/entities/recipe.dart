import 'package:eefood/features/recipe/data/models/category_model.dart';
import 'package:eefood/features/recipe/data/models/ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_Ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';
import 'package:eefood/features/recipe/domain/entities/recipe_ingredient.dart';

enum Difficulty { EASY, MEDIUM, HARD }

class Recipe {
  final int id;
  final String title;
  final String? description;
  final String? region;
  final String? imageUrl;
  final String? videoUrl;
  final Difficulty? difficulty;
  final int? cookTime; // in minutes
  final int? prepTime; // in minutes
  final List<CategoryModel>? categories;
  final List<RecipeIngredientModel>? ingredients;
  final List<RecipeStepModel>? steps;
  const Recipe({
    required this.id,
    required this.title,
    this.description,
    this.region,
    this.imageUrl,
    this.videoUrl,
    this.difficulty,
    this.prepTime,
    this.cookTime,
    this.categories,
    this.steps,
    this.ingredients,
  });
}
