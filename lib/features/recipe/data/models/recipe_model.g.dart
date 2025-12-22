// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeModel _$RecipeModelFromJson(Map<String, dynamic> json) => RecipeModel(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String,
  description: json['description'] as String?,
  region: json['region'] as String?,
  imageUrl: json['imageUrl'] as String?,
  videoUrl: json['videoUrl'] as String?,
  prepTime: (json['prepTime'] as num?)?.toInt(),
  cookTime: (json['cookTime'] as num?)?.toInt(),
  difficulty: $enumDecodeNullable(_$DifficultyEnumMap, json['difficulty']),
  categories: (json['categories'] as List<dynamic>?)
      ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  steps: (json['steps'] as List<dynamic>?)
      ?.map((e) => RecipeStepModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  ingredients: (json['ingredients'] as List<dynamic>?)
      ?.map((e) => RecipeIngredientModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RecipeModelToJson(RecipeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'region': instance.region,
      'imageUrl': instance.imageUrl,
      'videoUrl': instance.videoUrl,
      'prepTime': instance.prepTime,
      'cookTime': instance.cookTime,
      'difficulty': _$DifficultyEnumMap[instance.difficulty],
      'categories': instance.categories?.map((e) => e.toJson()).toList(),
      'steps': instance.steps?.map((e) => e.toJson()).toList(),
      'ingredients': instance.ingredients?.map((e) => e.toJson()).toList(),
    };

const _$DifficultyEnumMap = {
  Difficulty.EASY: 'EASY',
  Difficulty.MEDIUM: 'MEDIUM',
  Difficulty.HARD: 'HARD',
};
