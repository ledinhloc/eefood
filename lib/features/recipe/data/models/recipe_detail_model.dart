import 'package:eefood/features/recipe/data/models/recipe_Ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';

class RecipeDetailModel extends RecipeModel{
  final int userId;
  final String username;
  final String email;
  final String? avatarUrl;
  RecipeDetailModel({
    required this.userId,
    required this.username,
    required this.email,
    this.avatarUrl,
    required super.id,
    required super.title,
    super.description,
    super.imageUrl,
    super.videoUrl,
    super.difficulty,
    super.region,
    super.cookTime,
    super.prepTime,
    super.categoryIds,
    super.ingredients,
    super.steps,
  });

  factory RecipeDetailModel.fromJson(Map<String, dynamic> json) {
    return RecipeDetailModel(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      difficulty: RecipeModel.difficultyFromString(json['difficulty']),
      region: json['region'],
      cookTime: json['cookTime'],
      prepTime: json['prepTime'],
      categoryIds: (json['categories'] as List?)?.map((e) => e['id'] as int).toList(),
      ingredients: json['ingredients'] != null
          ? (json['ingredients'] as List)
          .map((e) => RecipeIngredientModel.fromJson(e))
          .toList()
          : [],
      steps: json['steps'] != null
          ? (json['steps'] as List)
          .map((e) => RecipeStepModel.fromJson(e))
          .toList()
          : [],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'],
    );
  }
}