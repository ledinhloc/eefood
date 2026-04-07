import 'package:json_annotation/json_annotation.dart';

part 'meal_plan_generate_request.g.dart';

@JsonSerializable()
class MealPlanGenerateRequest {
  final String? goal;
  final DateTime? startDate;
  final int? days;

  MealPlanGenerateRequest({
    this.goal,
    this.startDate,
    this.days,
  });

  factory MealPlanGenerateRequest.fromJson(Map<String, dynamic> json) =>
      _$MealPlanGenerateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MealPlanGenerateRequestToJson(this);
}
