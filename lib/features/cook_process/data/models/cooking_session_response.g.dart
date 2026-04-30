// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooking_session_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CookingSessionResponse _$CookingSessionResponseFromJson(
        Map<String, dynamic> json) =>
    CookingSessionResponse(
      sessionId: (json['sessionId'] as num?)?.toInt(),
      recipeId: (json['recipeId'] as num?)?.toInt(),
      recipeTitle: json['recipeTitle'] as String?,
      status:
          $enumDecodeNullable(_$CookingSessionStatusEnumMap, json['status']),
      currentStep: (json['currentStep'] as num?)?.toInt(),
      totalSteps: (json['totalSteps'] as num?)?.toInt(),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      steps: (json['steps'] as List<dynamic>?)
          ?.map((e) =>
              CookingSessionStepResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CookingSessionResponseToJson(
        CookingSessionResponse instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'recipeId': instance.recipeId,
      'recipeTitle': instance.recipeTitle,
      'status': _$CookingSessionStatusEnumMap[instance.status],
      'currentStep': instance.currentStep,
      'totalSteps': instance.totalSteps,
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'steps': instance.steps,
    };

const _$CookingSessionStatusEnumMap = {
  CookingSessionStatus.IN_PROGRESS: 'IN_PROGRESS',
  CookingSessionStatus.COMPLETED: 'COMPLETED',
};
