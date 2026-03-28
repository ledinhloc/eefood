// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan_item_ingredient_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealPlanItemIngredientResponse _$MealPlanItemIngredientResponseFromJson(
        Map<String, dynamic> json) =>
    MealPlanItemIngredientResponse(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      quantity: json['quantity'] as String?,
      unit: json['unit'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$MealPlanItemIngredientResponseToJson(
        MealPlanItemIngredientResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'note': instance.note,
    };
