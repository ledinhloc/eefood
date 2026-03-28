import 'package:json_annotation/json_annotation.dart';

import 'meal_plan_item_response.dart';

part 'meal_plan_response.g.dart';

@JsonSerializable(explicitToJson: true)
class MealPlanResponse {
  final int? id;
  final int? userId;
  final String? goal;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? note;
  final String? userHealthNote;
  final List<MealPlanItemResponse> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MealPlanResponse({
    this.id,
    this.userId,
    this.goal,
    this.startDate,
    this.endDate,
    this.note,
    this.userHealthNote,
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory MealPlanResponse.fromJson(Map<String, dynamic> json) =>
      _$MealPlanResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MealPlanResponseToJson(this);
}
