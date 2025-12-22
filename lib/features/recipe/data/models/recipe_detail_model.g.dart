// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeDetailModel _$RecipeDetailModelFromJson(Map<String, dynamic> json) =>
    RecipeDetailModel(
      userId: (json['userId'] as num).toInt(),
      username: json['username'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      region: json['region'] as String?,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      difficulty: $enumDecodeNullable(_$DifficultyEnumMap, json['difficulty']),
      prepTime: (json['prepTime'] as num?)?.toInt(),
      cookTime: (json['cookTime'] as num?)?.toInt(),
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      steps: (json['steps'] as List<dynamic>?)
          ?.map((e) => RecipeStepModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map(
            (e) => RecipeIngredientModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$RecipeDetailModelToJson(RecipeDetailModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'email': instance.email,
      'avatarUrl': instance.avatarUrl,
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'videoUrl': instance.videoUrl,
      'difficulty': _$DifficultyEnumMap[instance.difficulty],
      'region': instance.region,
      'cookTime': instance.cookTime,
      'prepTime': instance.prepTime,
      'categories': instance.categories?.map((e) => e.toJson()).toList(),
      'ingredients': instance.ingredients?.map((e) => e.toJson()).toList(),
      'steps': instance.steps?.map((e) => e.toJson()).toList(),
    };

const _$DifficultyEnumMap = {
  Difficulty.EASY: 'EASY',
  Difficulty.MEDIUM: 'MEDIUM',
  Difficulty.HARD: 'HARD',
};
