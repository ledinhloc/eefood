import 'package:eefood/features/recipe/data/models/recipe_compare_model.dart';
import 'package:eefood/features/recipe/presentation/widgets/compare_recipe/time_compare/time_compare_row.dart';
import 'package:flutter/material.dart';

class TimeCompareSection extends StatelessWidget {
  final RecipeCompareModel recipeA;
  final RecipeCompareModel recipeB;

  const TimeCompareSection({
    super.key,
    required this.recipeA,
    required this.recipeB,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.access_time_rounded,
                  color: Color(0xFFFF8C00),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Thời Gian Nấu',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TimeCompareRow(
            label: 'Chuẩn bị',
            valueA: recipeA.prepTime,
            valueB: recipeB.prepTime,
          ),
          const SizedBox(height: 10),
          TimeCompareRow(
            label: 'Nấu',
            valueA: recipeA.cookTime,
            valueB: recipeB.cookTime,
          ),
          const SizedBox(height: 10),
          TimeCompareRow(
            label: 'Tổng cộng',
            valueA: recipeA.totalTime,
            valueB: recipeB.totalTime,
            isTotal: true,
          ),
        ],
      ),
    );
  }
}
