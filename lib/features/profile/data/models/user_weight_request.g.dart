// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_weight_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserWeightRequest _$UserWeightRequestFromJson(Map<String, dynamic> json) =>
    UserWeightRequest(
      weightKg: (json['weightKg'] as num).toDouble(),
      recordedDate: _dateFromJson(json['recordedDate'] as String?),
    );

Map<String, dynamic> _$UserWeightRequestToJson(UserWeightRequest instance) =>
    <String, dynamic>{
      'weightKg': instance.weightKg,
      'recordedDate': _dateToJson(instance.recordedDate),
    };
