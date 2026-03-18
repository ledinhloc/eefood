import 'package:flutter/material.dart';

class MacroData {
  final String label;
  final double value;
  final Color color;
  final String unit;

  const MacroData(this.label, this.value, this.color, this.unit);
}

class NutrientItem {
  final String label;
  final double? value;
  final String unit;
  final Color color;
  final IconData icon;

  const NutrientItem(this.label, this.value, this.unit, this.color, this.icon);
}
