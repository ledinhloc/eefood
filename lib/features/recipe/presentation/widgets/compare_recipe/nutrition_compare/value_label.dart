import 'package:flutter/material.dart';

class ValueLabel extends StatelessWidget {
  final double value;
  final String unit;
  final Color color;
  final bool isBetter;
  const ValueLabel({
    super.key,
    required this.value,
    required this.unit,
    required this.color,
    required this.isBetter,
  });

  @override
  Widget build(BuildContext context) {
    final display = value == value.roundToDouble()
        ? '${value.toInt()}$unit'
        : '${value.toStringAsFixed(1)}$unit';

    return Text(
      display,
      style: TextStyle(
        fontSize: 11,
        fontWeight: isBetter ? FontWeight.w700 : FontWeight.w500,
        color: isBetter ? color : const Color(0xFF888888),
      ),
    );
  }
}
