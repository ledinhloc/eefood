// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_compare_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeCompareModel _$RecipeCompareModelFromJson(Map<String, dynamic> json) =>
    RecipeCompareModel(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String?,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      prepTime: (json['prepTime'] as num?)?.toInt(),
      cookTime: (json['cookTime'] as num?)?.toInt(),
      totalTime: (json['totalTime'] as num?)?.toInt(),
      difficulty: json['difficulty'] as String?,
      region: json['region'] as String?,
      stepCount: (json['stepCount'] as num?)?.toInt(),
      ingredientCount: (json['ingredientCount'] as num?)?.toInt(),
      calories: (json['calories'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
      carb: (json['carb'] as num?)?.toDouble(),
      fiber: (json['fiber'] as num?)?.toDouble(),
      sugar: (json['sugar'] as num?)?.toDouble(),
      cal: (json['cal'] as num?)?.toDouble(),
      sodium: (json['sodium'] as num?)?.toDouble(),
      healthScore: (json['healthScore'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$RecipeCompareModelToJson(RecipeCompareModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'imageUrl': instance.imageUrl,
      'videoUrl': instance.videoUrl,
      'prepTime': instance.prepTime,
      'cookTime': instance.cookTime,
      'totalTime': instance.totalTime,
      'difficulty': instance.difficulty,
      'region': instance.region,
      'stepCount': instance.stepCount,
      'ingredientCount': instance.ingredientCount,
      'calories': instance.calories,
      'protein': instance.protein,
      'fat': instance.fat,
      'carb': instance.carb,
      'fiber': instance.fiber,
      'sugar': instance.sugar,
      'cal': instance.cal,
      'sodium': instance.sodium,
      'healthScore': instance.healthScore,
    };
