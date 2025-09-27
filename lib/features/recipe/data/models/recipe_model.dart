import 'package:eefood/features/recipe/data/models/category_model.dart';
import 'package:eefood/features/recipe/data/models/ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_Ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';
import 'package:eefood/features/recipe/domain/entities/recipe.dart';
import 'package:eefood/features/recipe/domain/entities/recipe_ingredient.dart';

class RecipeModel {
  String title;
  String? description;
  String? imageUrl;
  String? videoUrl;
  Difficulty? difficulty;
  String? region;
  int? cookTime; // in minutes
  int? prepTime; // in minutes
  List<int>? categoryIds;
  List<RecipeIngredientModel>? ingredients;
  List<RecipeStepModel>? steps;
  RecipeModel({
    required this.title,
    this.description,
    this.region,
    this.imageUrl,
    this.videoUrl,
    this.difficulty,
    this.prepTime,
    this.cookTime,
    this.categoryIds,
    this.steps,
    this.ingredients,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      difficulty: _difficultyFromString(json['difficulty']),
      region: json['region'],
      cookTime: json['cookTime'],
      prepTime: json['prepTime'],
      categoryIds: json['categoryIds'] != null
          ? List<int>.from(json['categoryIds'])
          : null,
      ingredients: json['ingredients'] != null
          ? List<RecipeIngredientModel>.from(json['ingredients'])
          : null,
      steps: json['steps'] != null
          ? List<RecipeStepModel>.from(json['steps'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'difficulty': difficulty?.name,
      'region': region,
      'cookTime': cookTime,
      'prepTime': prepTime,
      'categoryIds': categoryIds,
      'ingredients': ingredients?.map((ing) => ing.toJson()).toList(),
      'steps': steps?.map((step) => step.toJson()).toList(),
    };
  }

  Recipe toEntity() => Recipe(
    title: title,
    description: description,
    imageUrl: imageUrl,
    videoUrl: videoUrl,
    difficulty: difficulty,
    region: region,
    cookTime: cookTime,
    prepTime: prepTime,
    categoryIds: categoryIds,
    ingredients: ingredients,
    steps: steps,
  );

  static Difficulty? _difficultyFromString(String? value) {
    if (value == null) return null;
    return Difficulty.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => Difficulty.EASY,
    );
  }

  RecipeModel copyWith({
    String? title,
    String? description,
    String? imageUrl,
    String? videoUrl,
    Difficulty? difficulty,
    String? region,
    int? cookTime,
    int? prepTime,
    List<int>? categoryIds,
    List<RecipeIngredientModel>? ingredients,
    List<RecipeStepModel>? steps,
  }) {
    return RecipeModel(
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      difficulty: difficulty ?? this.difficulty,
      region: region ?? this.region,
      cookTime: cookTime ?? this.cookTime,
      prepTime: prepTime ?? this.prepTime,
      categoryIds: categoryIds ?? this.categoryIds,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
    );
  }
}
