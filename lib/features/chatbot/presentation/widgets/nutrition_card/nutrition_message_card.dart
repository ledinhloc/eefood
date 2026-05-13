import 'package:eefood/features/chatbot/data/models/nutrition_macro_item.dart';
import 'package:eefood/features/chatbot/presentation/widgets/nutrition_card/nutrition_card_header.dart';
import 'package:eefood/features/chatbot/presentation/widgets/nutrition_card/nutrition_expandable_section.dart';
import 'package:eefood/features/chatbot/presentation/widgets/nutrition_card/nutrition_marco_grid.dart';
import 'package:eefood/features/chatbot/presentation/widgets/nutrition_card/nutrition_recommendation_banner.dart';
import 'package:eefood/features/chatbot/presentation/widgets/nutrition_card/nutrition_score_section.dart';
import 'package:eefood/features/chatbot/presentation/widgets/nutrition_card/nutrition_summary_bubble.dart';
import 'package:eefood/features/nutrition/data/models/nutrition_analysis_model.dart';
import 'package:flutter/material.dart';

class NutritionMessageCard extends StatefulWidget {
  final NutritionAnalysisModel nutrition;
  final bool animate;

  const NutritionMessageCard({
    super.key,
    required this.nutrition,
    this.animate = false,
  });

  @override
  State<NutritionMessageCard> createState() => _NutritionMessageCardState();
}

class _NutritionMessageCardState extends State<NutritionMessageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scoreAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    if (widget.animate) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _healthColor(double? score) {
    if (score == null) return Colors.grey;
    if (score >= 80) return const Color(0xFF2ECC71);
    if (score >= 60) return const Color(0xFFF39C12);
    if (score >= 40) return const Color(0xFFE67E22);
    return const Color(0xFFE74C3C);
  }

  List<NutritionMacroItem> _buildMacros(NutritionAnalysisModel n) => [
    NutritionMacroItem(
      label: 'Protein',
      value: n.totalProtein,
      unit: 'g',
      color: const Color(0xFF3498DB),
      icon: Icons.fitness_center_rounded,
    ),
    NutritionMacroItem(
      label: 'Carb',
      value: n.totalCarb,
      unit: 'g',
      color: const Color(0xFFF39C12),
      icon: Icons.grain_rounded,
    ),
    NutritionMacroItem(
      label: 'Fat',
      value: n.totalFat,
      unit: 'g',
      color: const Color(0xFFE74C3C),
      icon: Icons.water_drop_outlined,
    ),
    NutritionMacroItem(
      label: 'Fiber',
      value: n.totalFiber,
      unit: 'g',
      color: const Color(0xFF2ECC71),
      icon: Icons.eco_rounded,
    ),
  ];

  List<NutritionMicroItem> _buildMicros(NutritionAnalysisModel n) => [
    if (n.totalSugar != null)
      NutritionMicroItem('Đường', n.totalSugar!, 'g', const Color(0xFFE91E63)),
    if (n.totalCalcium != null)
      NutritionMicroItem(
        'Canxi',
        n.totalCalcium!,
        'g',
        const Color(0xFF9C27B0),
      ),
    if (n.totalSodium != null)
      NutritionMicroItem('Natri', n.totalSodium!, 'g', const Color(0xFF607D8B)),
  ];

  @override
  Widget build(BuildContext context) {
    final n = widget.nutrition;
    final color = _healthColor(n.healthScore);

    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NutritionCardHeader(nutrition: n, color: color),
            NutritionScoreSection(
              score: n.healthScore,
              color: color,
              level: n.healthLevel,
              totalCalories: n.totalCalories,
              animation: _scoreAnimation,
            ),
            if (n.summary != null && n.summary!.isNotEmpty)
              NutritionSummaryBubble(summary: n.summary!),
            NutritionMarcoGrid(macros: _buildMacros(n)),
            Divider(height: 1, color: Colors.grey.shade100),
            NutritionExpandableSection(
              microItems: _buildMicros(n),
              ingredientDetails: n.ingredientDetails,
            ),
            if (n.recommendation != null && n.recommendation!.isNotEmpty)
              NutritionRecommendationBanner(
                summary: n.summary!,
                recommendation: n.recommendation!,
              ),
          ],
        ),
      ),
    );
  }
}
