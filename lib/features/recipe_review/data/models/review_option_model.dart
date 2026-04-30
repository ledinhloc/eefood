import 'package:json_annotation/json_annotation.dart';

part 'review_option_model.g.dart';

@JsonSerializable()
class ReviewOptionModel {
  final int? id;
  final String? content;
  final int? starValue;

  ReviewOptionModel({this.id, this.content, this.starValue});

  factory ReviewOptionModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewOptionModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewOptionModelToJson(this);
}
