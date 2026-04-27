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
      recordedDate: _dateFromJson(json['recordedDate'] as String?),
    );

Map<String, dynamic> _$UserHeightResponseToJson(UserHeightResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'heightCm': instance.heightCm,
      'recordedDate': _dateToJson(instance.recordedDate),
    };
