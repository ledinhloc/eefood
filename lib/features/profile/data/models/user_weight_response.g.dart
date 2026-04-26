// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_weight_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserWeightResponse _$UserWeightResponseFromJson(Map<String, dynamic> json) =>
    UserWeightResponse(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      weightKg: (json['weightKg'] as num).toDouble(),
      recordedAt: json['recordedAt'] == null
          ? null
          : DateTime.parse(json['recordedAt'] as String),
    );

Map<String, dynamic> _$UserWeightResponseToJson(UserWeightResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'weightKg': instance.weightKg,
      'recordedAt': instance.recordedAt?.toIso8601String(),
    };
