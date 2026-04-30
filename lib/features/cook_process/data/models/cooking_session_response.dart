import 'package:eefood/features/cook_process/data/models/cooking_session_step_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cooking_session_response.g.dart';

enum CookingSessionStatus { IN_PROGRESS, COMPLETED }

@JsonSerializable()
class CookingSessionResponse {
  final int? sessionId;
  final int? recipeId;
  final String? recipeTitle;
  final CookingSessionStatus? status;
  final int? currentStep;
  final int? totalSteps;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final List<CookingSessionStepResponse>? steps;

  CookingSessionResponse({
    this.sessionId,
    this.recipeId,
    this.recipeTitle,
    this.status,
    this.currentStep,
    this.totalSteps,
    this.startedAt,
    this.completedAt,
    this.steps,
  });

  factory CookingSessionResponse.fromJson(Map<String, dynamic> json) =>
      _$CookingSessionResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CookingSessionResponseToJson(this);
}
