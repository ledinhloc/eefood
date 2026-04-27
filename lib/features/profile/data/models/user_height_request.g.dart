// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_height_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserHeightRequest _$UserHeightRequestFromJson(Map<String, dynamic> json) =>
    UserHeightRequest(
      heightCm: (json['heightCm'] as num).toDouble(),
      recordedDate: _dateFromJson(json['recordedDate'] as String?),
    );

Map<String, dynamic> _$UserHeightRequestToJson(UserHeightRequest instance) =>
    <String, dynamic>{
      'heightCm': instance.heightCm,
      'recordedDate': _dateToJson(instance.recordedDate),
    };
