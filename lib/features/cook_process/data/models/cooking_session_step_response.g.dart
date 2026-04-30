// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooking_session_step_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CookingSessionStepResponse _$CookingSessionStepResponseFromJson(
        Map<String, dynamic> json) =>
    CookingSessionStepResponse(
      cookingSessionStepId: (json['cookingSessionStepId'] as num?)?.toInt(),
      recipeStepId: (json['recipeStepId'] as num?)?.toInt(),
      stepNumber: (json['stepNumber'] as num?)?.toInt(),
      instruction: json['instruction'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      videoUrls: (json['videoUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      stepTime: (json['stepTime'] as num?)?.toInt(),
      status: $enumDecodeNullable(_$CookingStepStatusEnumMap, json['status']),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$CookingSessionStepResponseToJson(
        CookingSessionStepResponse instance) =>
    <String, dynamic>{
      'cookingSessionStepId': instance.cookingSessionStepId,
      'recipeStepId': instance.recipeStepId,
      'stepNumber': instance.stepNumber,
      'instruction': instance.instruction,
      'imageUrls': instance.imageUrls,
      'videoUrls': instance.videoUrls,
      'stepTime': instance.stepTime,
      'status': _$CookingStepStatusEnumMap[instance.status],
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };

const _$CookingStepStatusEnumMap = {
  CookingStepStatus.PENDING: 'PENDING',
  CookingStepStatus.IN_PROGRESS: 'IN_PROGRESS',
  CookingStepStatus.DONE: 'DONE',
};
