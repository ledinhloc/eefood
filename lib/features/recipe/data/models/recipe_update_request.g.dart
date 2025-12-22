// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeUpdateRequest _$RecipeUpdateRequestFromJson(Map<String, dynamic> json) =>
    RecipeUpdateRequest(
      title: json['title'] as String,
      description: json['description'] as String?,
      region: json['region'] as String?,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      prepTime: (json['prepTime'] as num?)?.toInt(),
      cookTime: (json['cookTime'] as num?)?.toInt(),
      difficulty: json['difficulty'] as String?,
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
    );

Map<String, dynamic> _$RecipeUpdateRequestToJson(
  RecipeUpdateRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'region': instance.region,
  'imageUrl': instance.imageUrl,
  'videoUrl': instance.videoUrl,
  'prepTime': instance.prepTime,
  'cookTime': instance.cookTime,
  'difficulty': instance.difficulty,
  'categories': instance.categories,
  'ingredients': instance.ingredients,
  'steps': instance.steps,
};
