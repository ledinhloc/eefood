import 'package:eefood/features/nutrition/presentation/widgets/skeleton/shimmer_box.dart';
import 'package:flutter/material.dart';

class AnalysisSkeleton extends StatefulWidget {
   final bool isDark;
  const AnalysisSkeleton({super.key, required this.isDark});

  @override
  State<AnalysisSkeleton> createState() => _AnalysisSkeletonState();
}

class _AnalysisSkeletonState extends State<AnalysisSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = widget.isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final shimmerBase = widget.isDark
        ? Colors.white10
        : Colors.black.withOpacity(0.06);
    final shimmerHighlight = widget.isDark
        ? Colors.white24
        : Colors.black.withOpacity(0.12);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Score dial skeleton
            AnimatedBuilder(
              animation: _shimmer,
              builder: (_, __) {
                final t = _shimmer.value;
                final color = Color.lerp(shimmerBase, shimmerHighlight, t)!;
                return Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                );
              },
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 80, height: 12, isDark: widget.isDark),
                  const SizedBox(height: 8),
                  ShimmerBox(width: 120, height: 18, isDark: widget.isDark),
                  const SizedBox(height: 8),
                  ShimmerBox(
                    width: double.infinity,
                    height: 12,
                    isDark: widget.isDark,
                  ),
                  const SizedBox(height: 4),
                  ShimmerBox(width: 160, height: 12, isDark: widget.isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}