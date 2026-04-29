import 'package:eefood/features/recipe_review/data/models/option_state_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'question_state_model.g.dart';

@JsonSerializable()
class QuestionStateModel {
  final int? questionId;
  final String? content;
  final int? weight;
  final List<OptionStateModel>? options;
  QuestionStateModel({
    this.questionId,
    this.content,
    this.weight,
    this.options,
  });

  factory QuestionStateModel.fromJson(Map<String, dynamic> json) => _$QuestionStateModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionStateModelToJson(this);
}
