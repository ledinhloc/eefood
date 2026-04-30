import 'package:eefood/app_routes.dart';
import 'package:eefood/features/recipe_review/data/models/recipe_review_stats_model.dart';
import 'package:flutter/material.dart';

class RatingSummaryWidget extends StatelessWidget {
  final RecipeReviewStatsModel stats;
  const RatingSummaryWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final avg = stats.avgRating ?? 0.0;
    final total = stats.totalReviews ?? 0;
    final dist = stats.ratingDistribution ?? {};
    final maxCount = dist.values.fold(0, (a, b) => a > b ? a : b);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Đánh giá công thức",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (stats.questionStats == null ||
                        stats.questionStats!.isEmpty)
                      return;
                    Navigator.pushNamed(
                      context,
                      AppRoutes.reviewStatsDetailPage,
                      arguments: {'stats': stats},
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.orange),
                    ),
                  ),
                  child: const Text(
                    "Xem chi tiết",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left: điểm trung bình
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      avg.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w800,
                        color: Colors.orange,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _StarRow(rating: avg),
                    const SizedBox(height: 4),
                    Text(
                      "$total đánh giá",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 20),

                // Right: Horizontal bar chart tự vẽ
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(5, (i) {
                      final star = 5 - i; 
                      final count = dist[star] ?? 0;
                      final ratio = maxCount > 0 ? count / maxCount : 0.0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            // Label sao bên trái
                            SizedBox(
                              width: 24,
                              child: Text(
                                '$star★',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black45,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Bar
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: ratio.toDouble(),
                                  minHeight: 10,
                                  backgroundColor: Colors.grey.shade100,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _barColor(star),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Số lượng bên phải
                            SizedBox(
                              width: 24,
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _barColor(int star) {
    switch (star) {
      case 5:
        return Colors.orange;
      case 4:
        return Colors.orange.shade300;
      case 3:
        return Colors.amber.shade300;
      case 2:
        return Colors.orange.shade200;
      default:
        return Colors.grey.shade300;
    }
  }
}

class _StarRow extends StatelessWidget {
  final double rating;
  const _StarRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star_rounded, color: Colors.orange, size: 16);
        } else if (i < rating) {
          return const Icon(
            Icons.star_half_rounded,
            color: Colors.orange,
            size: 16,
          );
        }
        return const Icon(
          Icons.star_outline_rounded,
          color: Colors.orange,
          size: 16,
        );
      }),
    );
  }
}
