import 'package:flutter/material.dart';

class NutritionMacroItem {
  final String label;
  final double? value;
  final String unit;
  final Color color;
  final IconData icon;

  const NutritionMacroItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
  });
}

class NutritionMicroItem {
  final String label;
  final double value;
  final String unit;
  final Color color;

  const NutritionMicroItem(this.label, this.value, this.unit, this.color);
}
