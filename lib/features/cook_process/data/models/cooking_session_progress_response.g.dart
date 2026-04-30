// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooking_session_progress_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CookingSessionProgressResponse _$CookingSessionProgressResponseFromJson(
        Map<String, dynamic> json) =>
    CookingSessionProgressResponse(
      sessionId: (json['sessionId'] as num?)?.toInt(),
      currentStep: (json['currentStep'] as num?)?.toInt(),
      totalSteps: (json['totalSteps'] as num?)?.toInt(),
      status:
          $enumDecodeNullable(_$CookingSessionStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$CookingSessionProgressResponseToJson(
        CookingSessionProgressResponse instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'currentStep': instance.currentStep,
      'totalSteps': instance.totalSteps,
      'status': _$CookingSessionStatusEnumMap[instance.status],
    };

const _$CookingSessionStatusEnumMap = {
  CookingSessionStatus.IN_PROGRESS: 'IN_PROGRESS',
  CookingSessionStatus.COMPLETED: 'COMPLETED',
};
