import 'package:flutter/material.dart';

class NutritionRow {
  final String label;
  final String unitA;
  final String unitB;
  final double valueA;
  final double valueB;
  final bool lowerIsBetter;
  final IconData icon;
  final Color iconColor;
  const NutritionRow({
    required this.label,
    required this.unitA,
    required this.unitB,
    required this.valueA,
    required this.valueB,
    required this.lowerIsBetter,
    required this.icon,
    required this.iconColor,
  });
}
