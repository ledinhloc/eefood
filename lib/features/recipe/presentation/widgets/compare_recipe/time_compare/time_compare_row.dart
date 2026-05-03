import 'package:eefood/features/recipe/presentation/widgets/compare_recipe/time_compare/value_badge_compare.dart';
import 'package:flutter/material.dart';

class TimeCompareRow extends StatelessWidget {
  final String label;
  final int? valueA;
  final int? valueB;
  final bool isTotal;
  const TimeCompareRow({
    super.key,
    required this.label,
    required this.valueA,
    required this.valueB,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = valueA ?? 0;
    final b = valueB ?? 0;
    final isAFaster = a > 0 && b > 0 && a < b;
    final isBFaster = a > 0 && b > 0 && b < a;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isTotal ? const Color(0xFFF6F4F1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isTotal ? Border.all(color: const Color(0xFFE8E4DE)) : null,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: ValueBadgeCompare(
              value: _format(a),
              color: const Color(0xFFE8534A),
              isBetter: isAFaster,
              isTotal: isTotal,
            ),
          ),
          Expanded(
            flex: 4,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isTotal ? 12 : 11,
                  color: const Color(0xFF888888),
                  fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: ValueBadgeCompare(
                value: _format(b),
                color: const Color(0xFF2C9E6E),
                isBetter: isBFaster,
                isTotal: isTotal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _format(int minutes) {
    if (minutes == 0) return '-';
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h${m}m';
  }
}
