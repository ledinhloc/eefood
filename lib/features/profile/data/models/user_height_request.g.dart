// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_height_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserHeightRequest _$UserHeightRequestFromJson(Map<String, dynamic> json) =>
    UserHeightRequest(
      heightCm: (json['heightCm'] as num).toDouble(),
      recordedAt: json['recordedAt'] == null
          ? null
          : DateTime.parse(json['recordedAt'] as String),
    );

Map<String, dynamic> _$UserHeightRequestToJson(UserHeightRequest instance) =>
    <String, dynamic>{
      'heightCm': instance.heightCm,
      'recordedAt': instance.recordedAt?.toIso8601String(),
    };
