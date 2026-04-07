import 'package:json_annotation/json_annotation.dart';

import '../../domain/enum/meal_plan_item_source.dart';
import '../../domain/enum/meal_plan_item_status.dart';
import '../../domain/enum/meal_slot.dart';
import 'meal_plan_item_ingredient_response.dart';

part 'meal_plan_item_response.g.dart';

@JsonSerializable(explicitToJson: true)
class MealPlanItemResponse {
  final int? id;
  final DateTime? planDate;
  @JsonKey(unknownEnumValue: MealSlot.breakfast)
  final MealSlot mealSlot;
  final int? itemOrder;
  @JsonKey(unknownEnumValue: MealPlanItemSource.recipe)
  final MealPlanItemSource itemSource;
  final int? recipeId;
  final int? postId;
  final String? customMealName;
  final int? plannedServings;
  final int? actualServings;
  @JsonKey(unknownEnumValue: MealPlanItemStatus.planned)
  final MealPlanItemStatus status;
  final String? recipeTitle;
  final String? imageUrl;
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final double? fiber;
  final double? sugar;
  final double? calcium;
  final double? sodium;
  final String? note;
  final List<MealPlanItemIngredientResponse> ingredients;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MealPlanItemResponse({
    this.id,
    this.planDate,
    required this.mealSlot,
    this.itemOrder,
    required this.itemSource,
    this.recipeId,
    this.postId,
    this.customMealName,
    this.plannedServings,
    this.actualServings,
    required this.status,
    this.recipeTitle,
    this.imageUrl,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.fiber,
    this.sugar,
    this.calcium,
    this.sodium,
    this.note,
    this.ingredients = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory MealPlanItemResponse.fromJson(Map<String, dynamic> json) =>
      _$MealPlanItemResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MealPlanItemResponseToJson(this);
}
