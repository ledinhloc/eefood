import 'package:json_annotation/json_annotation.dart';

part 'user_weight_response.g.dart';

@JsonSerializable()
class UserWeightResponse {
  final int id;
  final int userId;
  final double weightKg;
  final DateTime? recordedAt;

  const UserWeightResponse({
    required this.id,
    required this.userId,
    required this.weightKg,
    this.recordedAt,
  });

  factory UserWeightResponse.fromJson(Map<String, dynamic> json) =>
      _$UserWeightResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserWeightResponseToJson(this);
}
