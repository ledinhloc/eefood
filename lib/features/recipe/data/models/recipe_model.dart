import 'package:eefood/features/recipe/data/models/category_model.dart';
import 'package:eefood/features/recipe/data/models/ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_Ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';
import 'package:eefood/features/recipe/domain/entities/recipe.dart';
import 'package:eefood/features/recipe/domain/entities/recipe_ingredient.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recipe_model.g.dart';

@JsonSerializable(explicitToJson: true)
class RecipeModel {
  final int? id;
  final String title;
  final String? description;
  final String? region;
  final String? imageUrl;
  final String? videoUrl;
  final int? prepTime;
  final int? cookTime;
  final Difficulty? difficulty;

  final List<CategoryModel>? categories;
  final List<RecipeStepModel>? steps;
  final List<RecipeIngredientModel>? ingredients;
  RecipeModel({
    this.id,
    required this.title,
    this.description,
    this.region,
    this.imageUrl,
    this.videoUrl,
    this.prepTime,
    this.cookTime,
    this.difficulty,
    this.categories,
    this.steps,
    this.ingredients,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) =>
      _$RecipeModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeModelToJson(this);

  RecipeModel copyWith({
    int? id,
    String? title,
    String? description,
    String? region,
    String? imageUrl,
    String? videoUrl,
    int? prepTime,
    int? cookTime,
    Difficulty? difficulty,
    List<CategoryModel>? categories,
    List<RecipeStepModel>? steps,
    List<RecipeIngredientModel>? ingredients,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      region: region ?? this.region,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      difficulty: difficulty ?? this.difficulty,
      categories: categories ?? this.categories,
      steps: steps ?? this.steps,
      ingredients: ingredients ?? this.ingredients,
    );
  }
}
