import 'package:eefood/features/recipe/data/models/recipe_compare_response.dart';
import 'package:eefood/features/recipe/presentation/widgets/compare_recipe/health_score/health_score_section.dart';
import 'package:eefood/features/recipe/presentation/widgets/compare_recipe/nutrition_compare/nutrition_section_wrapper.dart';
import 'package:eefood/features/recipe/presentation/widgets/compare_recipe/recipe_card_compare.dart';
import 'package:eefood/features/recipe/presentation/widgets/compare_recipe/time_compare/time_compare_section.dart';
import 'package:eefood/features/recipe/presentation/widgets/compare_recipe/vs_divider.dart';
import 'package:flutter/material.dart';

class CompareContent extends StatelessWidget {
  final RecipeCompareResponse data;
  const CompareContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final recipeA = data.recipeA;
    final recipeB = data.recipeB;

    if (recipeA == null || recipeB == null) {
      return const Center(child: Text('Dữ liệu không hợp lệ'));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Recipe Cards Side by Side
          Row(
            children: [
              Expanded(
                child: RecipeCardCompare(
                  recipe: recipeA,
                  label: 'A',
                  color: const Color(0xFFE8534A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RecipeCardCompare(
                  recipe: recipeB,
                  label: 'B',
                  color: const Color(0xFF2C9E6E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // VS divider
          VsDivider(recipeA: recipeA, recipeB: recipeB),
          const SizedBox(height: 20),
          // Time Comparison
          TimeCompareSection(recipeA: recipeA, recipeB: recipeB),
          const SizedBox(height: 16),
          // Nutrition Comparison
          NutritionSectionWrapper(recipeA: recipeA, recipeB: recipeB),
          const SizedBox(height: 16),
          // Health Score
          HealthScoreSection(recipeA: recipeA, recipeB: recipeB),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
