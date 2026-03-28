// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan_item_ingredient_upsert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealPlanItemIngredientUpsertRequest
    _$MealPlanItemIngredientUpsertRequestFromJson(Map<String, dynamic> json) =>
        MealPlanItemIngredientUpsertRequest(
          name: json['name'] as String?,
          quantity: json['quantity'] as String?,
          unit: json['unit'] as String?,
          note: json['note'] as String?,
        );

Map<String, dynamic> _$MealPlanItemIngredientUpsertRequestToJson(
        MealPlanItemIngredientUpsertRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'note': instance.note,
    };
