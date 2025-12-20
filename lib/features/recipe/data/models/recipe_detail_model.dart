import 'package:eefood/features/recipe/data/models/category_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_Ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/recipe.dart';

part 'recipe_detail_model.g.dart';

@JsonSerializable(explicitToJson: true)
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
  factory RecipeDetailModel.fromJson(Map<String, dynamic> json) =>
      _$RecipeDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeDetailModelToJson(this);

}