// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_analysis_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NutritionAnalysisModel _$NutritionAnalysisModelFromJson(
        Map<String, dynamic> json) =>
    NutritionAnalysisModel(
      recipeId: (json['recipeId'] as num).toInt(),
      recipeTitle: json['recipeTitle'] as String,
      totalCalories: (json['totalCalories'] as num?)?.toDouble(),
      totalProtein: (json['totalProtein'] as num?)?.toDouble(),
      totalFat: (json['totalFat'] as num?)?.toDouble(),
      totalCarb: (json['totalCarb'] as num?)?.toDouble(),
      totalFiber: (json['totalFiber'] as num?)?.toDouble(),
      totalSugar: (json['totalSugar'] as num?)?.toDouble(),
      totalCalcium: (json['totalCalcium'] as num?)?.toDouble(),
      totalSodium: (json['totalSodium'] as num?)?.toDouble(),
      healthScore: (json['healthScore'] as num?)?.toDouble(),
      healthLevel: json['healthLevel'] as String?,
      summary: json['summary'] as String?,
      recommendation: json['recommendation'] as String?,
      ingredientDetails: (json['ingredientDetails'] as List<dynamic>?)
          ?.map((e) => IngredientNutritionDetailModel.fromJson(
              e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NutritionAnalysisModelToJson(
        NutritionAnalysisModel instance) =>
    <String, dynamic>{
      'recipeId': instance.recipeId,
      'recipeTitle': instance.recipeTitle,
      'totalCalories': instance.totalCalories,
      'totalProtein': instance.totalProtein,
      'totalFat': instance.totalFat,
      'totalCarb': instance.totalCarb,
      'totalFiber': instance.totalFiber,
      'totalSugar': instance.totalSugar,
      'totalCalcium': instance.totalCalcium,
      'totalSodium': instance.totalSodium,
      'healthScore': instance.healthScore,
      'summary': instance.summary,
      'healthLevel': instance.healthLevel,
      'recommendation': instance.recommendation,
      'ingredientDetails': instance.ingredientDetails,
    };
