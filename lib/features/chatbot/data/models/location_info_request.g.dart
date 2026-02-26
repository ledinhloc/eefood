// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_info_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationInfoRequest _$LocationInfoRequestFromJson(Map<String, dynamic> json) =>
    LocationInfoRequest(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      province: json['province'] as String,
    );

Map<String, dynamic> _$LocationInfoRequestToJson(
  LocationInfoRequest instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'province': instance.province,
};
