import 'package:json_annotation/json_annotation.dart';

part 'meal_plan_item_ingredient_response.g.dart';

@JsonSerializable()
class MealPlanItemIngredientResponse {
  final int? id;
  final String? name;
  final String? quantity;
  final String? unit;
  final String? note;

  MealPlanItemIngredientResponse({
    this.id,
    this.name,
    this.quantity,
    this.unit,
    this.note,
  });

  factory MealPlanItemIngredientResponse.fromJson(Map<String, dynamic> json) =>
      _$MealPlanItemIngredientResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MealPlanItemIngredientResponseToJson(this);
}
