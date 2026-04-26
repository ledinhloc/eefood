import 'package:json_annotation/json_annotation.dart';

part 'user_height_response.g.dart';

@JsonSerializable()
class UserHeightResponse {
  final int id;
  final int userId;
  final double heightCm;
  final DateTime? recordedAt;

  const UserHeightResponse({
    required this.id,
    required this.userId,
    required this.heightCm,
    this.recordedAt,
  });

  factory UserHeightResponse.fromJson(Map<String, dynamic> json) =>
      _$UserHeightResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserHeightResponseToJson(this);
}
