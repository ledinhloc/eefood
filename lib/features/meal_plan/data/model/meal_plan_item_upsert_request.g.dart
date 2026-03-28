// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan_item_upsert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealPlanItemUpsertRequest _$MealPlanItemUpsertRequestFromJson(
        Map<String, dynamic> json) =>
    MealPlanItemUpsertRequest(
      id: (json['id'] as num?)?.toInt(),
      planDate: json['planDate'] == null
          ? null
          : DateTime.parse(json['planDate'] as String),
      mealSlot: $enumDecodeNullable(_$MealSlotEnumMap, json['mealSlot'],
          unknownValue: MealSlot.breakfast),
      itemOrder: (json['itemOrder'] as num?)?.toInt(),
      itemSource: $enumDecodeNullable(
          _$MealPlanItemSourceEnumMap, json['itemSource'],
          unknownValue: MealPlanItemSource.recipe),
      recipeId: (json['recipeId'] as num?)?.toInt(),
      postId: (json['postId'] as num?)?.toInt(),
      customMealName: json['customMealName'] as String?,
      plannedServings: (json['plannedServings'] as num?)?.toInt(),
      actualServings: (json['actualServings'] as num?)?.toInt(),
      status: $enumDecodeNullable(_$MealPlanItemStatusEnumMap, json['status'],
          unknownValue: MealPlanItemStatus.planned),
      note: json['note'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((e) => MealPlanItemIngredientUpsertRequest.fromJson(
              e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MealPlanItemUpsertRequestToJson(
        MealPlanItemUpsertRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'planDate': instance.planDate?.toIso8601String(),
      'mealSlot': _$MealSlotEnumMap[instance.mealSlot],
      'itemOrder': instance.itemOrder,
      'itemSource': _$MealPlanItemSourceEnumMap[instance.itemSource],
      'recipeId': instance.recipeId,
      'postId': instance.postId,
      'customMealName': instance.customMealName,
      'plannedServings': instance.plannedServings,
      'actualServings': instance.actualServings,
      'status': _$MealPlanItemStatusEnumMap[instance.status],
      'note': instance.note,
      'ingredients': instance.ingredients?.map((e) => e.toJson()).toList(),
    };

const _$MealSlotEnumMap = {
  MealSlot.breakfast: 'BREAKFAST',
  MealSlot.lunch: 'LUNCH',
  MealSlot.dinner: 'DINNER',
  MealSlot.snack: 'SNACK',
};

const _$MealPlanItemSourceEnumMap = {
  MealPlanItemSource.recipe: 'RECIPE',
  MealPlanItemSource.custom: 'CUSTOM',
};

const _$MealPlanItemStatusEnumMap = {
  MealPlanItemStatus.planned: 'PLANNED',
  MealPlanItemStatus.done: 'DONE',
  MealPlanItemStatus.skipped: 'SKIPPED',
};
