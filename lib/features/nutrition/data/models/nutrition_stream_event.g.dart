// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_stream_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NutritionStreamEvent _$NutritionStreamEventFromJson(
        Map<String, dynamic> json) =>
    NutritionStreamEvent(
      type: $enumDecode(_$NutritionEventTypeEnumMap, json['type']),
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : NutritionAnalysisModel.fromJson(
              json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NutritionStreamEventToJson(
        NutritionStreamEvent instance) =>
    <String, dynamic>{
      'type': _$NutritionEventTypeEnumMap[instance.type]!,
      'message': instance.message,
      'data': instance.data,
    };

const _$NutritionEventTypeEnumMap = {
  NutritionEventType.status: 'status',
  NutritionEventType.nutrition: 'nutrition',
  NutritionEventType.analysis: 'analysis',
  NutritionEventType.error: 'error',
  NutritionEventType.complete: 'complete',
};
