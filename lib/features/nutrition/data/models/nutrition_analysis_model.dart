import 'package:eefood/features/nutrition/data/models/ingredient_nutrition_detail_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'nutrition_analysis_model.g.dart';

@JsonSerializable()
class NutritionAnalysisModel {
  final int recipeId;
  final String recipeTitle;

  final double? totalCalories;
  final double? totalProtein;
  final double? totalFat;
  final double? totalCarb;
  final double? totalFiber;
  final double? totalSugar;
  final double? totalCalcium;
  final double? totalSodium;

  final double? healthScore;

  final String? summary;
  final String? healthLevel;
  final String? recommendation;

  final List<IngredientNutritionDetailModel>? ingredientDetails;

  NutritionAnalysisModel({
    required this.recipeId,
    required this.recipeTitle,

    this.totalCalories,
    this.totalProtein,
    this.totalFat,
    this.totalCarb,
    this.totalFiber,
    this.totalSugar,
    this.totalCalcium,
    this.totalSodium,
    this.healthScore,
    this.healthLevel,
    this.summary,
    this.recommendation,

    this.ingredientDetails,
  });

  factory NutritionAnalysisModel.fromJson(Map<String, dynamic> json) =>
      _$NutritionAnalysisModelFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionAnalysisModelToJson(this);
}
