import 'package:json_annotation/json_annotation.dart';

part 'user_height_request.g.dart';

@JsonSerializable()
class UserHeightRequest {
  final double heightCm;
  final DateTime? recordedAt;

  const UserHeightRequest({required this.heightCm, this.recordedAt});

  factory UserHeightRequest.fromJson(Map<String, dynamic> json) =>
      _$UserHeightRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UserHeightRequestToJson(this);
}
