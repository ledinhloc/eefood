// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_weight_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserWeightRequest _$UserWeightRequestFromJson(Map<String, dynamic> json) =>
    UserWeightRequest(
      weightKg: (json['weightKg'] as num).toDouble(),
      recordedAt: json['recordedAt'] == null
          ? null
          : DateTime.parse(json['recordedAt'] as String),
    );

Map<String, dynamic> _$UserWeightRequestToJson(UserWeightRequest instance) =>
    <String, dynamic>{
      'weightKg': instance.weightKg,
      'recordedAt': instance.recordedAt?.toIso8601String(),
    };
