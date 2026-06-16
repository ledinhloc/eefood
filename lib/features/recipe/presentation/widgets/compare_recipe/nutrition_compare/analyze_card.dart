import 'dart:math';

import 'package:eefood/features/recipe/data/models/recipe_compare_model.dart';
import 'package:flutter/material.dart';

class AnalyzeCard extends StatelessWidget {
  final RecipeCompareModel recipe;
  final String label;
  final Color color;
  final bool hasNutrition;
  final bool isAnalyzing;
  final String? error;
  final AnimationController rotateController;
  final Animation<double> pulseAnim;
  final VoidCallback onAnalyze;
  const AnalyzeCard({
    super.key,
    required this.recipe,
    required this.label,
    required this.color,
    required this.hasNutrition,
    required this.isAnalyzing,
    this.error,
    required this.rotateController,
    required this.pulseAnim,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAnalyzing ? color.withOpacity(0.5) : color.withOpacity(0.15),
          width: isAnalyzing ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Label badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (hasNutrition)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: Color(0xFF2E7D32),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Recipe name
          Text(
            recipe.title ?? 'Công thức $label',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Status
          if (hasNutrition)
            _DoneChip()
          else if (isAnalyzing)
            _AnalyzingIndicator(
              color: color,
              rotateController: rotateController,
              pulseAnim: pulseAnim,
            )
          else if (error != null)
            _ErrorRetry(color: color, onRetry: onAnalyze)
          else
            _AnalyzeButton(color: color, onTap: onAnalyze),
        ],
      ),
    );
  }
}

class _DoneChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 12, color: Color(0xFF16A34A)),
          SizedBox(width: 4),
          Text(
            'Đã có dữ liệu',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF16A34A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyzingIndicator extends StatelessWidget {
  final Color color;
  final AnimationController rotateController;
  final Animation<double> pulseAnim;

  const _AnalyzingIndicator({
    required this.color,
    required this.rotateController,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScaleTransition(
          scale: pulseAnim,
          child: AnimatedBuilder(
            animation: rotateController,
            builder: (_, child) => Transform.rotate(
              angle: rotateController.value * 2 * pi,
              child: child,
            ),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [color.withOpacity(0.1), color],
                  stops: const [0.0, 1.0],
                ),
              ),
              child: Center(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.04),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Đang phân tích...',
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final Color color;
  final VoidCallback onRetry;

  const _ErrorRetry({required this.color, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 20,
          color: Color(0xFFDC2626),
        ),
        const SizedBox(height: 4),
        const Text(
          'Phân tích thất bại',
          style: TextStyle(fontSize: 11, color: Color(0xFFDC2626)),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: color.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Thử lại',
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnalyzeButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _AnalyzeButton({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.22),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, size: 12, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'Phân tích AI',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
