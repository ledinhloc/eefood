// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeCreateRequest _$RecipeCreateRequestFromJson(Map<String, dynamic> json) =>
    RecipeCreateRequest(
      title: json['title'] as String,
      cookTime: (json['cookTime'] as num).toInt(),
      prepTime: (json['prepTime'] as num).toInt(),
      categories: (json['categories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      ingredients: (json['ingredients'] as List<dynamic>)
          .map(
            (e) => IngredientCreateRequest.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      steps: (json['steps'] as List<dynamic>)
          .map((e) => RecipeStepModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      region: json['region'] as String?,
      difficulty: json['difficulty'] as String?,
    );

Map<String, dynamic> _$RecipeCreateRequestToJson(
  RecipeCreateRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
  'videoUrl': instance.videoUrl,
  'region': instance.region,
  'cookTime': instance.cookTime,
  'prepTime': instance.prepTime,
  'difficulty': instance.difficulty,
  'categories': instance.categories,
  'ingredients': instance.ingredients,
  'steps': instance.steps,
};
