// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealPlanResponse _$MealPlanResponseFromJson(Map<String, dynamic> json) =>
    MealPlanResponse(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num?)?.toInt(),
      goal: json['goal'] as String?,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      note: json['note'] as String?,
      userHealthNote: json['userHealthNote'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) =>
                  MealPlanItemResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MealPlanResponseToJson(MealPlanResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'goal': instance.goal,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'note': instance.note,
      'userHealthNote': instance.userHealthNote,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
