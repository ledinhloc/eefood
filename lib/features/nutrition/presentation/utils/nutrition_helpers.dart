import 'package:eefood/features/nutrition/data/models/nutrition_analysis_model.dart';
import 'package:eefood/features/nutrition/data/models/nutrition_display_models.dart';
import 'package:flutter/material.dart';

List<MacroData> buildMacroData(NutritionAnalysisModel data) {
  final items = [
    MacroData('Năng lượng', data.totalCalories ?? 0, const Color(0xFFFF8F00), 'g'),
    MacroData('Protein', data.totalProtein ?? 0, const Color(0xFF4FC3F7), 'g'),
    MacroData('Chất béo', data.totalFat ?? 0, const Color(0xFFFFB74D), 'g'),
    MacroData('Carb', data.totalCarb ?? 0, const Color(0xFF81C784), 'g'),
    MacroData('Chất xơ', data.totalFiber ?? 0, const Color(0xFFBA68C8), 'g'),
  ];
  return items.where((m) => m.value > 0).toList();
}

List<NutrientItem> buildNutrientItems(NutritionAnalysisModel data) {
  return [
    NutrientItem(
      'Calories',
      data.totalCalories,
      'kcal',
      const Color(0xFFFF6B00),
      Icons.local_fire_department_rounded,
    ),
    NutrientItem(
      'Protein',
      data.totalProtein,
      'g',
      const Color(0xFF4FC3F7),
      Icons.fitness_center_rounded,
    ),
    NutrientItem(
      'Chất béo',
      data.totalFat,
      'g',
      const Color(0xFFFFB74D),
      Icons.opacity_rounded,
    ),
    NutrientItem(
      'Carb',
      data.totalCarb,
      'g',
      const Color(0xFF81C784),
      Icons.grain_rounded,
    ),
    NutrientItem(
      'Chất xơ',
      data.totalFiber,
      'g',
      const Color(0xFFBA68C8),
      Icons.eco_rounded,
    ),
    NutrientItem(
      'Đường',
      data.totalSugar,
      'g',
      const Color(0xFFF06292),
      Icons.icecream_rounded,
    ),
    NutrientItem(
      'Calcium',
      data.totalCalcium,
      'mg',
      const Color(0xFF64B5F6), 
      Icons.health_and_safety_rounded, 
    ),
    NutrientItem(
      'Sodium',
      data.totalSodium,
      'mg',
      const Color(0xFF90A4AE), 
      Icons.science_rounded, 
    ),
  ];
}

Color healthScoreColor(double score) {
  if (score >= 8) return const Color(0xFF00C896);
  if (score >= 6) return const Color(0xFFFF6B00);
  if (score >= 4) return const Color(0xFFFFB74D);
  return Colors.redAccent;
}

const List<Color> ingredientAccentColors = [
  Color(0xFFFF6B00),
  Color(0xFF4FC3F7),
  Color(0xFF81C784),
  Color(0xFFFFB74D),
  Color(0xFFBA68C8),
  Color(0xFFF06292),
];
