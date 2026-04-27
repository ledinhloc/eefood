import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

part 'user_weight_request.g.dart';

@JsonSerializable()
class UserWeightRequest {
  final double weightKg;
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime? recordedDate;

  const UserWeightRequest({required this.weightKg, this.recordedDate});

  factory UserWeightRequest.fromJson(Map<String, dynamic> json) =>
      _$UserWeightRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UserWeightRequestToJson(this);
}

DateTime? _dateFromJson(String? value) {
  if (value == null) return null;
  return DateTime.parse(value);
}

String? _dateToJson(DateTime? value) {
  if (value == null) return null;
  return DateFormat('yyyy-MM-dd').format(value);
}
