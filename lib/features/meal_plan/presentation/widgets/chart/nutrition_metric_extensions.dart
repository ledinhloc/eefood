import 'package:eefood/features/meal_plan/data/model/meal_plan_daily_summary_response.dart';
import 'package:eefood/features/meal_plan/domain/enum/nutrition_metric.dart';
import 'package:flutter/material.dart';

extension NutritionMetricX on NutritionMetric {
  String get label {
    switch (this) {
      case NutritionMetric.calories:
        return 'Calo';
      case NutritionMetric.protein:
        return 'Protein';
      case NutritionMetric.carbs:
        return 'Carbs';
      case NutritionMetric.fat:
        return 'Chất béo';
      case NutritionMetric.fiber:
        return 'Chất xơ';
      case NutritionMetric.sugar:
        return 'Đường';
      case NutritionMetric.sodium:
        return 'Natri';
      case NutritionMetric.calcium:
        return 'Canxi';
    }
  }

  Color color(bool isDark) {
    switch (this) {
      case NutritionMetric.calories:
        return isDark ? const Color(0xFFFFB347) : const Color(0xFFE76F00);
      case NutritionMetric.protein:
        return isDark ? const Color(0xFFFF8A80) : const Color(0xFFD9485F);
      case NutritionMetric.carbs:
        return isDark ? const Color(0xFFFFD166) : const Color(0xFFEE9B00);
      case NutritionMetric.fat:
        return isDark ? const Color(0xFF95D5B2) : const Color(0xFF2A9D8F);
      case NutritionMetric.fiber:
        return isDark ? const Color(0xFF90CAF9) : const Color(0xFF457B9D);
      case NutritionMetric.sugar:
        return isDark ? const Color(0xFFF8A5C2) : const Color(0xFFD65A8C);
      case NutritionMetric.sodium:
        return isDark ? const Color(0xFFC3BEF0) : const Color(0xFF7B6FD6);
      case NutritionMetric.calcium:
        return isDark ? const Color(0xFFBDE0FE) : const Color(0xFF4895EF);
    }
  }

  double valueFrom(MealPlanDailySummaryResponse summary) {
    switch (this) {
      case NutritionMetric.calories:
        return summary.calories ?? 0;
      case NutritionMetric.protein:
        return summary.protein ?? 0;
      case NutritionMetric.carbs:
        return summary.carbs ?? 0;
      case NutritionMetric.fat:
        return summary.fat ?? 0;
      case NutritionMetric.fiber:
        return summary.fiber ?? 0;
      case NutritionMetric.sugar:
        return summary.sugar ?? 0;
      case NutritionMetric.sodium:
        return summary.sodium ?? 0;
      case NutritionMetric.calcium:
        return summary.calcium ?? 0;
    }
  }
}
