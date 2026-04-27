import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

part 'user_height_response.g.dart';

@JsonSerializable()
class UserHeightResponse {
  final int id;
  final int userId;
  final double heightCm;
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime? recordedDate;

  const UserHeightResponse({
    required this.id,
    required this.userId,
    required this.heightCm,
    this.recordedDate,
  });

  factory UserHeightResponse.fromJson(Map<String, dynamic> json) =>
      _$UserHeightResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserHeightResponseToJson(this);
}

DateTime? _dateFromJson(String? value) {
  if (value == null) return null;
  return DateTime.parse(value);
}

String? _dateToJson(DateTime? value) {
  if (value == null) return null;
  return DateFormat('yyyy-MM-dd').format(value);
}
