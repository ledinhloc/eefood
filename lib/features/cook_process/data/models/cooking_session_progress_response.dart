import 'package:eefood/features/cook_process/data/models/cooking_session_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cooking_session_progress_response.g.dart';

@JsonSerializable()
class CookingSessionProgressResponse {
  final int? sessionId;
  final int? currentStep;
  final int? totalSteps;
  final CookingSessionStatus? status;

  CookingSessionProgressResponse({this.sessionId, this.currentStep, this.totalSteps, this.status});

  factory CookingSessionProgressResponse.fromJson(Map<String, dynamic> json) =>
      _$CookingSessionProgressResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CookingSessionProgressResponseToJson(this);
}