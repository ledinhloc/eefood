// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan_daily_summary_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealPlanDailySummaryResponse _$MealPlanDailySummaryResponseFromJson(
        Map<String, dynamic> json) =>
    MealPlanDailySummaryResponse(
      planDate: json['planDate'] == null
          ? null
          : DateTime.parse(json['planDate'] as String),
      calories: (json['calories'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
      fiber: (json['fiber'] as num?)?.toDouble(),
      sugar: (json['sugar'] as num?)?.toDouble(),
      sodium: (json['sodium'] as num?)?.toDouble(),
      calcium: (json['calcium'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$MealPlanDailySummaryResponseToJson(
        MealPlanDailySummaryResponse instance) =>
    <String, dynamic>{
      'planDate': instance.planDate?.toIso8601String(),
      'calories': instance.calories,
      'protein': instance.protein,
      'carbs': instance.carbs,
      'fat': instance.fat,
      'fiber': instance.fiber,
      'sugar': instance.sugar,
      'sodium': instance.sodium,
      'calcium': instance.calcium,
    };
