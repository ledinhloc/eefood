import 'package:flutter/material.dart';

class InfoNutritionBadge extends StatelessWidget {
  final bool hasNutritionA;
  final bool hasNutritionB;
  final String titleA;
  final String titleB;
  const InfoNutritionBadge({
    super.key,
    required this.hasNutritionA,
    required this.hasNutritionB,
    required this.titleA,
    required this.titleB,
  });

  @override
  Widget build(BuildContext context) {
     final missing = <String>[];
    if (!hasNutritionA) missing.add('"$titleA"');
    if (!hasNutritionB) missing.add('"$titleB"');
    final namesText = missing.join(' và ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: Color(0xFFD97706),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$namesText chưa có dữ liệu dinh dưỡng. Phân tích AI để so sánh.',
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF92400E),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
