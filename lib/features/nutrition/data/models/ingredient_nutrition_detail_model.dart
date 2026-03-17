import 'package:json_annotation/json_annotation.dart';

part 'ingredient_nutrition_detail_model.g.dart';

@JsonSerializable()
class IngredientNutritionDetailModel {
  final String? ingredientName;
  final double? quantity;
  final String? unit;

  final double? calories;
  final double? protein;
  final double? fat;
  final double? carb;
  final double? fiber;
  final double? sugar;
  final double? calcium;
  final double? sodium;

  IngredientNutritionDetailModel({
    this.ingredientName,
    this.quantity,
    this.unit,
    this.calories,
    this.protein,
    this.fat,
    this.carb,
    this.fiber,
    this.sugar,
    this.calcium,
    this.sodium,
  });

  factory IngredientNutritionDetailModel.fromJson(Map<String, dynamic> json) =>
      _$IngredientNutritionDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$IngredientNutritionDetailModelToJson(this);
}
