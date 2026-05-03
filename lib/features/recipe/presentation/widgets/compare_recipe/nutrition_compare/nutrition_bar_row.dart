import 'package:eefood/features/recipe/data/models/nutrition_row.dart';
import 'package:eefood/features/recipe/presentation/widgets/compare_recipe/nutrition_compare/animate_bar.dart';
import 'package:eefood/features/recipe/presentation/widgets/compare_recipe/nutrition_compare/value_label.dart';
import 'package:flutter/material.dart';

class NutritionBarRow extends StatelessWidget {
  final NutritionRow row;
  final double progress;
  const NutritionBarRow({super.key, required this.row, required this.progress});

  @override
  Widget build(BuildContext context) {
    final total = row.valueA + row.valueB;
    final ratioA = total > 0 ? row.valueA / total : 0.5;
    final ratioB = total > 0 ? row.valueB / total : 0.5;

    final aBetter = row.lowerIsBetter
        ? (row.valueA < row.valueB)
        : (row.valueA > row.valueB);
    final bBetter = row.lowerIsBetter
        ? (row.valueB < row.valueA)
        : (row.valueB > row.valueA);

    final noData = row.valueA == 0 && row.valueB == 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(row.icon, size: 13, color: row.iconColor),
            const SizedBox(width: 6),
            Text(
              row.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF444444),
              ),
            ),
            const Spacer(),
            if (noData)
              const Text(
                'Chưa có dữ liệu',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFFBBBBBB),
                  fontStyle: FontStyle.italic,
                ),
              )
            else ...[
              ValueLabel(
                value: row.valueA,
                unit: row.unitA,
                color: const Color(0xFFE8534A),
                isBetter: aBetter,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 1,
                height: 12,
                color: const Color(0xFFE0E0E0),
              ),
              ValueLabel(
                value: row.valueB,
                unit: row.unitB,
                color: const Color(0xFF2C9E6E),
                isBetter: bBetter,
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        if (!noData) ...[
          // Bar A
          AnimateBar(
            ratio: ratioA * progress,
            color: const Color(0xFFE8534A),
            isBetter: aBetter,
          ),
          const SizedBox(height: 4),
          // Bar B
          AnimateBar(
            ratio: ratioB * progress,
            color: const Color(0xFF2C9E6E),
            isBetter: bBetter,
          ),
        ] else ...[
          _EmptyBar(),
          const SizedBox(height: 4),
          _EmptyBar(),
        ],
      ],
    );
  }
}

class _EmptyBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
