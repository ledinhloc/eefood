import 'package:json_annotation/json_annotation.dart';

part 'meal_plan_upsert_request.g.dart';

@JsonSerializable()
class MealPlanUpsertRequest {
  final String? goal;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? note;
  final String? userHealthNote;

  MealPlanUpsertRequest({
    this.goal,
    this.startDate,
    this.endDate,
    this.note,
    this.userHealthNote,
  });

  factory MealPlanUpsertRequest.fromJson(Map<String, dynamic> json) =>
      _$MealPlanUpsertRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MealPlanUpsertRequestToJson(this);
}
