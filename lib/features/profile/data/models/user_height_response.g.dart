// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_height_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserHeightResponse _$UserHeightResponseFromJson(Map<String, dynamic> json) =>
    UserHeightResponse(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      heightCm: (json['heightCm'] as num).toDouble(),
      recordedAt: json['recordedAt'] == null
          ? null
          : DateTime.parse(json['recordedAt'] as String),
    );

Map<String, dynamic> _$UserHeightResponseToJson(UserHeightResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'heightCm': instance.heightCm,
      'recordedAt': instance.recordedAt?.toIso8601String(),
    };
