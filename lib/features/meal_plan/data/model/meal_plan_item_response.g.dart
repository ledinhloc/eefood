// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan_item_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealPlanItemResponse _$MealPlanItemResponseFromJson(
        Map<String, dynamic> json) =>
    MealPlanItemResponse(
      id: (json['id'] as num?)?.toInt(),
      planDate: json['planDate'] == null
          ? null
          : DateTime.parse(json['planDate'] as String),
      mealSlot: $enumDecode(_$MealSlotEnumMap, json['mealSlot'],
          unknownValue: MealSlot.breakfast),
      itemOrder: (json['itemOrder'] as num?)?.toInt(),
      itemSource: $enumDecode(_$MealPlanItemSourceEnumMap, json['itemSource'],
          unknownValue: MealPlanItemSource.recipe),
      recipeId: (json['recipeId'] as num?)?.toInt(),
      postId: (json['postId'] as num?)?.toInt(),
      customMealName: json['customMealName'] as String?,
      plannedServings: (json['plannedServings'] as num?)?.toInt(),
      actualServings: (json['actualServings'] as num?)?.toInt(),
      status: $enumDecode(_$MealPlanItemStatusEnumMap, json['status'],
          unknownValue: MealPlanItemStatus.planned),
      recipeTitle: json['recipeTitle'] as String?,
      imageUrl: json['imageUrl'] as String?,
      calories: (json['calories'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
      fiber: (json['fiber'] as num?)?.toDouble(),
      sugar: (json['sugar'] as num?)?.toDouble(),
      calcium: (json['calcium'] as num?)?.toDouble(),
      sodium: (json['sodium'] as num?)?.toDouble(),
      note: json['note'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => MealPlanItemIngredientResponse.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MealPlanItemResponseToJson(
        MealPlanItemResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'planDate': instance.planDate?.toIso8601String(),
      'mealSlot': _$MealSlotEnumMap[instance.mealSlot]!,
      'itemOrder': instance.itemOrder,
      'itemSource': _$MealPlanItemSourceEnumMap[instance.itemSource]!,
      'recipeId': instance.recipeId,
      'postId': instance.postId,
      'customMealName': instance.customMealName,
      'plannedServings': instance.plannedServings,
      'actualServings': instance.actualServings,
      'status': _$MealPlanItemStatusEnumMap[instance.status]!,
      'recipeTitle': instance.recipeTitle,
      'imageUrl': instance.imageUrl,
      'calories': instance.calories,
      'protein': instance.protein,
      'carbs': instance.carbs,
      'fat': instance.fat,
      'fiber': instance.fiber,
      'sugar': instance.sugar,
      'calcium': instance.calcium,
      'sodium': instance.sodium,
      'note': instance.note,
      'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
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
