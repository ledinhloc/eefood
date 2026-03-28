import 'package:json_annotation/json_annotation.dart';

part 'meal_plan_item_ingredient_upsert_request.g.dart';

@JsonSerializable()
class MealPlanItemIngredientUpsertRequest {
  final String? name;
  final String? quantity;
  final String? unit;
  final String? note;

  MealPlanItemIngredientUpsertRequest({
    this.name,
    this.quantity,
    this.unit,
    this.note,
  });

  factory MealPlanItemIngredientUpsertRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$MealPlanItemIngredientUpsertRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MealPlanItemIngredientUpsertRequestToJson(this);
}
