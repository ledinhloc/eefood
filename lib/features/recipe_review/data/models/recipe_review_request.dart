import 'package:json_annotation/json_annotation.dart';

part 'recipe_review_request.g.dart';

@JsonSerializable()
class RecipeReviewRequest {
  final int? questionId;
  final int? optionId;
  final int? starValue;

  RecipeReviewRequest({this.questionId, this.optionId, this.starValue});

  factory RecipeReviewRequest.fromJson(Map<String, dynamic> json) =>
      _$RecipeReviewRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeReviewRequestToJson(this);
}
