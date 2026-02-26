import 'package:json_annotation/json_annotation.dart';

part 'location_info_request.g.dart';

@JsonSerializable()
class LocationInfoRequest {
  final double latitude;
  final double longitude;
  final String province;

  LocationInfoRequest({
    required this.latitude,
    required this.longitude,
    required this.province,
  });

  factory LocationInfoRequest.fromJson(Map<String, dynamic> json) =>
      _$LocationInfoRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LocationInfoRequestToJson(this);
}
