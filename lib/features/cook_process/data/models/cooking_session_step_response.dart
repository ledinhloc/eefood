import 'package:json_annotation/json_annotation.dart';

part 'cooking_session_step_response.g.dart';

enum CookingStepStatus { PENDING, IN_PROGRESS, DONE }

@JsonSerializable()
class CookingSessionStepResponse {
  final int? cookingSessionStepId;
  final int? recipeStepId;
  final int? stepNumber;
  final String? instruction;
  final List<String>? imageUrls;
  final List<String>? videoUrls;
  final int? stepTime;
  final CookingStepStatus? status;
  final DateTime? startedAt;
  final DateTime? completedAt;

  CookingSessionStepResponse({
    this.cookingSessionStepId,
    this.recipeStepId,
    this.stepNumber,
    this.instruction,
    this.imageUrls,
    this.videoUrls,
    this.stepTime,
    this.status,
    this.startedAt,
    this.completedAt,
  });

  factory CookingSessionStepResponse.fromJson(Map<String, dynamic> json) =>
      _$CookingSessionStepResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CookingSessionStepResponseToJson(this);
}
