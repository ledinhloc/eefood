import 'package:json_annotation/json_annotation.dart';

part 'option_state_model.g.dart';

@JsonSerializable()
class OptionStateModel {
  final int? optionId;
  final String? content;
  final int? count;
  final double? percent;

  OptionStateModel({this.optionId, this.content, this.count, this.percent});

  factory OptionStateModel.fromJson(Map<String, dynamic> json) =>
      _$OptionStateModelFromJson(json);

  Map<String, dynamic> toJson() => _$OptionStateModelToJson(this);
}
