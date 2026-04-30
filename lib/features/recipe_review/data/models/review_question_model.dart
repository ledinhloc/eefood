import 'package:eefood/features/recipe_review/data/models/review_option_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_question_model.g.dart';

@JsonSerializable()
class ReviewQuestionModel {
  final int? id;
  final String? content;
  final int? weight;
  final bool? isActive;
  final List<ReviewOptionModel>? options;

  ReviewQuestionModel({
    this.id,
    this.content,
    this.weight,
    this.isActive,
    this.options,
  });

  factory ReviewQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewQuestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewQuestionModelToJson(this);
}
