import 'package:eefood/features/recipe/data/models/ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';
import 'package:eefood/features/recipe/domain/entities/recipe.dart';

class RecipeModel {
  int id;
  String title;
  String? description;
  String? imageUrl;
  String? videoUrl;
  Difficulty? difficulty;
  String? region;
  int? cookTime; // in minutes
  int? prepTime; // in minutes
  List<int>? categoryIds;
  List<IngredientModel>? ingredients;
  List<RecipeStepModel>? steps;
  RecipeModel({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.videoUrl,
    this.difficulty,
    this.region,
    this.cookTime,
    this.prepTime,
    this.categoryIds,
    this.ingredients,
    this.steps,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'],
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
      ingredients: json['ingredients'] != null ? List<IngredientModel>.from(json['ingredients']) : null,
      steps: json['steps'] !=null ? List<RecipeStepModel>.from(json['steps']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'difficulty': difficulty?.name, 
      'region': region,
      'cookTime': cookTime,
      'prepTime': prepTime,
      'categoryIds': categoryIds,
      'ingredients': ingredients,
      'steps': steps
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

  static Difficulty? _difficultyFromString(String? value) {
    if (value == null) return null;
    return Difficulty.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => Difficulty.EASY,
    );
  }
}
