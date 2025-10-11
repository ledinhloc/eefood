import 'package:eefood/features/recipe/data/models/category_model.dart';
import 'package:eefood/features/recipe/data/models/ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_Ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';
import 'package:eefood/features/recipe/domain/entities/recipe.dart';
import 'package:eefood/features/recipe/domain/entities/recipe_ingredient.dart';

class RecipeModel {
  int? id;
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
    this.id,
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
      id: json['id'] !=null ? json['id'] as int : 0,
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      difficulty: difficultyFromString(json['difficulty']),
      region: json['region'],
      cookTime: json['cookTime'],
      prepTime: json['prepTime'],
      categoryIds: (json['categories'] as List<dynamic>?)
          ?.map((e) => e['id'] as int)
          .toList(),
      ingredients: json['ingredients'] != null
          ? (json['ingredients'] as List)
                .map(
                  (e) =>
                      RecipeIngredientModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
      steps: json['steps'] != null
          ? (json['steps'] as List)
                .map((e) => RecipeStepModel.fromJson(e as Map<String, dynamic>))
                .toList()
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
    id: id,
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

  static Difficulty? difficultyFromString(String? value) {
    if (value == null) return null;
    return Difficulty.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => Difficulty.EASY,
    );
  }

  RecipeModel copyWith({
    int? id,
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
      id: id ?? this.id,
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
