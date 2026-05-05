import 'package:eefood/features/recipe/data/models/nutrition_row.dart';
import 'package:eefood/features/recipe/data/models/recipe_compare_model.dart';
import 'package:eefood/features/recipe/presentation/widgets/compare_recipe/nutrition_compare/legend_dot.dart';
import 'package:eefood/features/recipe/presentation/widgets/compare_recipe/nutrition_compare/nutrition_bar_row.dart';
import 'package:flutter/material.dart';

class NutritionCompareSection extends StatefulWidget {
  final RecipeCompareModel recipeA;
  final RecipeCompareModel recipeB;
  const NutritionCompareSection({
    super.key,
    required this.recipeA,
    required this.recipeB,
  });

  @override
  State<NutritionCompareSection> createState() =>
      _NutritionCompareSectionState();
}

class _NutritionCompareSectionState extends State<NutritionCompareSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rA = widget.recipeA;
    final rB = widget.recipeB;

    final rows = [
      NutritionRow(
        label: 'Calories',
        unitA: 'kcal',
        unitB: 'kcal',
        valueA: rA.calories ?? 0,
        valueB: rB.calories ?? 0,
        lowerIsBetter: true,
        icon: Icons.local_fire_department_rounded,
        iconColor: const Color(0xFFFF6B35),
      ),
      NutritionRow(
        label: 'Protein',
        unitA: 'g',
        unitB: 'g',
        valueA: rA.protein ?? 0,
        valueB: rB.protein ?? 0,
        lowerIsBetter: false,
        icon: Icons.fitness_center_rounded,
        iconColor: const Color(0xFF5C6BC0),
      ),
      NutritionRow(
        label: 'Chất béo',
        unitA: 'g',
        unitB: 'g',
        valueA: rA.fat ?? 0,
        valueB: rB.fat ?? 0,
        lowerIsBetter: true,
        icon: Icons.water_drop_rounded,
        iconColor: const Color(0xFFFFA726),
      ),
      NutritionRow(
        label: 'Carbs',
        unitA: 'g',
        unitB: 'g',
        valueA: rA.carb ?? 0,
        valueB: rB.carb ?? 0,
        lowerIsBetter: true,
        icon: Icons.grain_rounded,
        iconColor: const Color(0xFF66BB6A),
      ),
      NutritionRow(
        label: 'Chất xơ',
        unitA: 'g',
        unitB: 'g',
        valueA: rA.fiber ?? 0,
        valueB: rB.fiber ?? 0,
        lowerIsBetter: false,
        icon: Icons.eco_rounded,
        iconColor: const Color(0xFF26A69A),
      ),
      NutritionRow(
        label: 'Đường',
        unitA: 'g',
        unitB: 'g',
        valueA: rA.sugar ?? 0,
        valueB: rB.sugar ?? 0,
        lowerIsBetter: true,
        icon: Icons.bubble_chart_rounded,
        iconColor: const Color(0xFFEC407A),
      ),
      NutritionRow(
        label: 'Natri',
        unitA: 'mg',
        unitB: 'mg',
        valueA: rA.sodium ?? 0,
        valueB: rB.sodium ?? 0,
        lowerIsBetter: true,
        icon: Icons.science_rounded,
        iconColor: const Color(0xFF8D6E63),
      ),
    ];

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
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
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Color(0xFF2E7D32),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'So Sánh Dinh Dưỡng',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              // Legend
              LegendDot(color: const Color(0xFFE8534A), label: 'A'),
              const SizedBox(width: 10),
              LegendDot(color: const Color(0xFF2C9E6E), label: 'B'),
            ],
          ),
          const SizedBox(height: 20),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (_, __) =>
                    NutritionBarRow(row: row, progress: _animation.value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
