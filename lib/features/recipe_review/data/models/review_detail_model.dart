import 'package:json_annotation/json_annotation.dart';

part 'review_detail_model.g.dart';

@JsonSerializable()
class ReviewDetailModel {
  final int? reviewId;
  final int? userId;
  final String? name;
  final String? avatar;
  final double? rating;
  final DateTime? createdAt;
  final List<String>? tags;

  ReviewDetailModel({
    this.reviewId,
    this.userId,
    this.name,
    this.avatar,
    this.rating,
    this.createdAt,
    this.tags,
  });

  factory ReviewDetailModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewDetailModelToJson(this);
}
