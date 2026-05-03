import 'package:flutter/material.dart';

class ValueBadgeCompare extends StatelessWidget {
  final String value;
  final Color color;
  final bool isBetter;
  final bool isTotal;
  const ValueBadgeCompare({
    super.key,
    required this.value,
    required this.color,
    required this.isBetter,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isBetter) ...[
          Icon(Icons.bolt_rounded, size: 12, color: color),
          const SizedBox(width: 2),
        ],
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 14 : 13,
            fontWeight: isBetter || isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isBetter ? color : const Color(0xFF555555),
          ),
        ),
      ],
    );
  }
}
