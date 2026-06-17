import 'package:eefood/features/recipe/data/models/recipe_compare_model.dart';
import 'package:eefood/features/recipe/presentation/widgets/compare_recipe/nutrition_compare/analyze_all_button.dart';
import 'package:eefood/features/recipe/presentation/widgets/compare_recipe/nutrition_compare/analyze_card.dart';
import 'package:eefood/features/recipe/presentation/widgets/compare_recipe/nutrition_compare/both_analyze_view.dart';
import 'package:eefood/features/recipe/presentation/widgets/compare_recipe/nutrition_compare/info_nutrition_badge.dart';
import 'package:flutter/material.dart';

class NutritionAnalyzePrompt extends StatefulWidget {
  final RecipeCompareModel recipeA;
  final RecipeCompareModel recipeB;
  final bool hasNutritionA;
  final bool hasNutritionB;
  final bool isAnalyzingA;
  final bool isAnalyzingB;
  final String? errorA;
  final String? errorB;
  final VoidCallback onAnalyzeA;
  final VoidCallback onAnalyzeB;
  const NutritionAnalyzePrompt({
    super.key,
    required this.recipeA,
    required this.recipeB,
    required this.hasNutritionA,
    required this.hasNutritionB,
    required this.isAnalyzingA,
    required this.isAnalyzingB,
    this.errorA,
    this.errorB,
    required this.onAnalyzeA,
    required this.onAnalyzeB,
  });

  @override
  State<NutritionAnalyzePrompt> createState() => _NutritionAnalyzePromptState();
}

class _NutritionAnalyzePromptState extends State<NutritionAnalyzePrompt>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAnalyzingBoth = widget.isAnalyzingA && widget.isAnalyzingB;

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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FFF4),
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
            ],
          ),
          const SizedBox(height: 20),
          // Info banner
          InfoNutritionBadge(
            hasNutritionA: widget.hasNutritionA,
            hasNutritionB: widget.hasNutritionB,
            titleA: widget.recipeA.title ?? 'Công thức A',
            titleB: widget.recipeB.title ?? 'Công thức B',
          ),
          const SizedBox(height: 20),
          // Recipe cards với trạng thái analyze
          if (isAnalyzingBoth)
            BothAnalyzeView(
              rotateController: _rotateController,
              pulseAnim: _pulseAnim,
            )
          else
            Row(
              children: [
                Expanded(
                  child: AnalyzeCard(
                    recipe: widget.recipeA,
                    label: 'A',
                    color: const Color(0xFFE8534A),
                    hasNutrition: widget.hasNutritionA,
                    isAnalyzing: widget.isAnalyzingA,
                    error: widget.errorA,
                    rotateController: _rotateController,
                    pulseAnim: _pulseAnim,
                    onAnalyze: widget.onAnalyzeA,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnalyzeCard(
                    recipe: widget.recipeB,
                    label: 'B',
                    color: const Color(0xFF2C9E6E),
                    hasNutrition: widget.hasNutritionB,
                    isAnalyzing: widget.isAnalyzingB,
                    error: widget.errorB,
                    rotateController: _rotateController,
                    pulseAnim: _pulseAnim,
                    onAnalyze: widget.onAnalyzeB,
                  ),
                ),
              ],
            ),
          // Nút analyze all nếu cả 2 đều thiếu
          if (!widget.hasNutritionA &&
              !widget.hasNutritionB &&
              !widget.isAnalyzingA &&
              !widget.isAnalyzingB) ...[
            const SizedBox(height: 16),
            AnalyzeAllButton(
              onTap: () {
                widget.onAnalyzeA();
                widget.onAnalyzeB();
              },
            ),
          ],
        ],
      ),
    );
  }
}
