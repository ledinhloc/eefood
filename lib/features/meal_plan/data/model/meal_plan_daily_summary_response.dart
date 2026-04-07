import 'package:json_annotation/json_annotation.dart';

part 'meal_plan_daily_summary_response.g.dart';

@JsonSerializable()
class MealPlanDailySummaryResponse {
  final DateTime? planDate;
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final double? fiber;
  final double? sugar;
  final double? sodium;
  final double? calcium;

  MealPlanDailySummaryResponse({
    this.planDate,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.fiber,
    this.sugar,
    this.sodium,
    this.calcium,
  });

  factory MealPlanDailySummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$MealPlanDailySummaryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MealPlanDailySummaryResponseToJson(this);
}
