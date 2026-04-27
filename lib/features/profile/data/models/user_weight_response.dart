import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

part 'user_weight_response.g.dart';

@JsonSerializable()
class UserWeightResponse {
  final int id;
  final int userId;
  final double weightKg;
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime? recordedDate;

  const UserWeightResponse({
    required this.id,
    required this.userId,
    required this.weightKg,
    this.recordedDate,
  });

  factory UserWeightResponse.fromJson(Map<String, dynamic> json) =>
      _$UserWeightResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserWeightResponseToJson(this);
}

DateTime? _dateFromJson(String? value) {
  if (value == null) return null;
  return DateTime.parse(value);
}

String? _dateToJson(DateTime? value) {
  if (value == null) return null;
  return DateFormat('yyyy-MM-dd').format(value);
}
