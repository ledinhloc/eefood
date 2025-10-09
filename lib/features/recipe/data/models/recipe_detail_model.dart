import 'package:eefood/features/recipe/data/models/category_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_Ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';

import '../../domain/entities/recipe.dart';

class RecipeDetailModel{
  final int userId;
  final String username;
  final String email;
  final String? avatarUrl;

  int? id;
  String title;
  String? description;
  String? imageUrl;
  String? videoUrl;
  Difficulty? difficulty;
  String? region;
  int? cookTime; // in minutes
  int? prepTime; // in minutes
  List<CategoryModel>? categories;
  List<RecipeIngredientModel>? ingredients;
  List<RecipeStepModel>? steps;

  RecipeDetailModel({
    required this.userId,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.id,
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
      categories: json['categories'] != null
          ? (json['categories'] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList()
          : [],
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