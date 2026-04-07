// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan_upsert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealPlanUpsertRequest _$MealPlanUpsertRequestFromJson(
        Map<String, dynamic> json) =>
    MealPlanUpsertRequest(
      goal: json['goal'] as String?,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      note: json['note'] as String?,
      userHealthNote: json['userHealthNote'] as String?,
    );

Map<String, dynamic> _$MealPlanUpsertRequestToJson(
        MealPlanUpsertRequest instance) =>
    <String, dynamic>{
      'goal': instance.goal,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'note': instance.note,
      'userHealthNote': instance.userHealthNote,
    };
