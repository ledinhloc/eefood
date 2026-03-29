import 'package:eefood/features/nutrition/presentation/widgets/skeleton/shimmer_box.dart';
import 'package:flutter/material.dart';

class SumarySkeleton extends StatelessWidget {
  final bool isDark;
  const SumarySkeleton({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFF6B00).withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B00).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.tips_and_updates_rounded,
                    color: Color(0xFFFF6B00),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                ShimmerBox(width: 140, height: 14, isDark: isDark),
              ],
            ),
            const SizedBox(height: 16),
            ShimmerBox(width: double.infinity, height: 12, isDark: isDark),
            const SizedBox(height: 6),
            ShimmerBox(width: double.infinity, height: 12, isDark: isDark),
            const SizedBox(height: 6),
            ShimmerBox(width: 200, height: 12, isDark: isDark),
          ],
        ),
      ),
    );
  }
}
