// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_nutrition_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IngredientNutritionDetailModel _$IngredientNutritionDetailModelFromJson(
        Map<String, dynamic> json) =>
    IngredientNutritionDetailModel(
      ingredientName: json['ingredientName'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      calories: (json['calories'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
      carb: (json['carb'] as num?)?.toDouble(),
      fiber: (json['fiber'] as num?)?.toDouble(),
      sugar: (json['sugar'] as num?)?.toDouble(),
      calcium: (json['calcium'] as num?)?.toDouble(),
      sodium: (json['sodium'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$IngredientNutritionDetailModelToJson(
        IngredientNutritionDetailModel instance) =>
    <String, dynamic>{
      'ingredientName': instance.ingredientName,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'calories': instance.calories,
      'protein': instance.protein,
      'fat': instance.fat,
      'carb': instance.carb,
      'fiber': instance.fiber,
      'sugar': instance.sugar,
      'calcium': instance.calcium,
      'sodium': instance.sodium,
    };
