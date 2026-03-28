import 'package:json_annotation/json_annotation.dart';

import '../../domain/enum/meal_plan_item_source.dart';
import '../../domain/enum/meal_plan_item_status.dart';
import '../../domain/enum/meal_slot.dart';
import 'meal_plan_item_ingredient_upsert_request.dart';

part 'meal_plan_item_upsert_request.g.dart';

@JsonSerializable(explicitToJson: true)
class MealPlanItemUpsertRequest {
  final int? id;
  final DateTime? planDate;
  @JsonKey(unknownEnumValue: MealSlot.breakfast)
  final MealSlot? mealSlot;
  final int? itemOrder;
  @JsonKey(unknownEnumValue: MealPlanItemSource.recipe)
  final MealPlanItemSource? itemSource;
  final int? recipeId;
  final int? postId;
  final String? customMealName;
  final int? plannedServings;
  final int? actualServings;
  @JsonKey(unknownEnumValue: MealPlanItemStatus.planned)
  final MealPlanItemStatus? status;
  final String? note;
  final List<MealPlanItemIngredientUpsertRequest>? ingredients;

  MealPlanItemUpsertRequest({
    this.id,
    this.planDate,
    this.mealSlot,
    this.itemOrder,
    this.itemSource,
    this.recipeId,
    this.postId,
    this.customMealName,
    this.plannedServings,
    this.actualServings,
    this.status,
    this.note,
    this.ingredients,
  });

  factory MealPlanItemUpsertRequest.fromJson(Map<String, dynamic> json) =>
      _$MealPlanItemUpsertRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MealPlanItemUpsertRequestToJson(this);
}
