// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan_generate_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealPlanGenerateRequest _$MealPlanGenerateRequestFromJson(
        Map<String, dynamic> json) =>
    MealPlanGenerateRequest(
      goal: json['goal'] as String?,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      days: (json['days'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MealPlanGenerateRequestToJson(
        MealPlanGenerateRequest instance) =>
    <String, dynamic>{
      'goal': instance.goal,
      'startDate': instance.startDate?.toIso8601String(),
      'days': instance.days,
    };
