import 'package:json_annotation/json_annotation.dart';

part 'user_weight_request.g.dart';

@JsonSerializable()
class UserWeightRequest {
  final double weightKg;
  final DateTime? recordedAt;

  const UserWeightRequest({required this.weightKg, this.recordedAt});

  factory UserWeightRequest.fromJson(Map<String, dynamic> json) =>
      _$UserWeightRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UserWeightRequestToJson(this);
}
