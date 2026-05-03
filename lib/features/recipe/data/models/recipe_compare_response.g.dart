// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_compare_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeCompareResponse _$RecipeCompareResponseFromJson(
        Map<String, dynamic> json) =>
    RecipeCompareResponse(
      recipeA: json['recipeA'] == null
          ? null
          : RecipeCompareModel.fromJson(
              json['recipeA'] as Map<String, dynamic>),
      recipeB: json['recipeB'] == null
          ? null
          : RecipeCompareModel.fromJson(
              json['recipeB'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RecipeCompareResponseToJson(
        RecipeCompareResponse instance) =>
    <String, dynamic>{
      'recipeA': instance.recipeA,
      'recipeB': instance.recipeB,
    };
