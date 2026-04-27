import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

part 'user_height_request.g.dart';

@JsonSerializable()
class UserHeightRequest {
  final double heightCm;
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime? recordedDate;

  const UserHeightRequest({required this.heightCm, this.recordedDate});

  factory UserHeightRequest.fromJson(Map<String, dynamic> json) =>
      _$UserHeightRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UserHeightRequestToJson(this);
}

DateTime? _dateFromJson(String? value) {
  if (value == null) return null;
  return DateTime.parse(value);
}

String? _dateToJson(DateTime? value) {
  if (value == null) return null;
  return DateFormat('yyyy-MM-dd').format(value);
}
