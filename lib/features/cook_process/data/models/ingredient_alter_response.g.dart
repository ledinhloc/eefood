// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_alter_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IngredientAlterModel _$IngredientAlterModelFromJson(
        Map<String, dynamic> json) =>
    IngredientAlterModel(
      ingredient: json['ingredient'] == null
          ? null
          : IngredientModel.fromJson(
              json['ingredient'] as Map<String, dynamic>),
      selectedSubstitute: json['selectedSubstitute'] == null
          ? null
          : IngredientModel.fromJson(
              json['selectedSubstitute'] as Map<String, dynamic>),
      substitute: (json['substitute'] as List<dynamic>?)
          ?.map((e) => IngredientModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$IngredientAlterModelToJson(
        IngredientAlterModel instance) =>
    <String, dynamic>{
      'ingredient': instance.ingredient,
      'selectedSubstitute': instance.selectedSubstitute,
      'substitute': instance.substitute,
    };
