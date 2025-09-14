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
  List<String>? dietaryPreferences;
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
    this.dietaryPreferences,
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
      dietaryPreferences: json['dietaryPreferences'] != null
          ? List<String>.from(json['dietaryPreferences'])
          : null,
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
      'dietaryPreferences': dietaryPreferences,
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
      dietaryPreferences: dietaryPreferences,
    );

  static Difficulty? _difficultyFromString(String? value) {
    if (value == null) return null;
    return Difficulty.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => Difficulty.EASY,
    );
  }
}
