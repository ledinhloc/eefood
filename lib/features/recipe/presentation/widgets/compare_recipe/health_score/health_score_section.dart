import 'package:eefood/features/recipe/data/models/recipe_compare_model.dart';
import 'package:eefood/features/recipe/presentation/widgets/compare_recipe/health_score/health_score_card.dart';
import 'package:eefood/features/recipe/presentation/widgets/compare_recipe/health_score/winner_banner.dart';
import 'package:flutter/material.dart';

class HealthScoreSection extends StatefulWidget {
  final RecipeCompareModel recipeA;
  final RecipeCompareModel recipeB;

  const HealthScoreSection({
    super.key,
    required this.recipeA,
    required this.recipeB,
  });

  @override
  State<HealthScoreSection> createState() => _HealthScoreSectionState();
}

class _HealthScoreSectionState extends State<HealthScoreSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    Future.delayed(const Duration(milliseconds: 500), () {
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
    final scoreA = widget.recipeA.healthScore ?? 0;
    final scoreB = widget.recipeB.healthScore ?? 0;
    final noData = scoreA == 0 && scoreB == 0;

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
                  color: const Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFFE91E63),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Điểm Sức Khoẻ',
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
          if (noData)
            _NoDataPlaceholder()
          else
            AnimatedBuilder(
              animation: _animation,
              builder: (_, __) => Row(
                children: [
                  Expanded(
                    child: HealthScoreCard(
                      label: 'Recipe A',
                      score: scoreA,
                      maxScore: 100,
                      color: const Color(0xFFE8534A),
                      progress: _animation.value,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: HealthScoreCard(
                      label: 'Recipe B',
                      score: scoreB,
                      maxScore: 100,
                      color: const Color(0xFF2C9E6E),
                      progress: _animation.value,
                    ),
                  ),
                ],
              ),
            ),
          if (!noData) ...[
            const SizedBox(height: 16),
            WinnerBanner(scoreA: scoreA, scoreB: scoreB),
          ],
        ],
      ),
    );
  }
}

class _NoDataPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.grey[400], size: 32),
          const SizedBox(height: 8),
          Text(
            'Chưa có điểm sức khoẻ cho 2 công thức này',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
