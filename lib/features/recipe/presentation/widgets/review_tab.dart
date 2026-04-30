import 'package:eefood/app_routes.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/recipe_review/domain/repositories/review_recipe_repository.dart';
import 'package:eefood/features/recipe_review/presentation/provider/review_stats_cubit.dart';
import 'package:eefood/features/recipe_review/presentation/widgets/list_review/review_card.dart';
import 'package:eefood/features/recipe_review/presentation/widgets/rating_summary_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReviewTab extends StatefulWidget {
  final int recipeId;
  final String recipeTitle;
  const ReviewTab({
    super.key,
    required this.recipeId,
    required this.recipeTitle,
  });

  @override
  State<ReviewTab> createState() => _ReviewTabState();
}

class _ReviewTabState extends State<ReviewTab> {
  late final ReviewStatsCubit _statsCubit;

  @override
  void initState() {
    super.initState();
    _statsCubit = ReviewStatsCubit(repository: getIt<ReviewRecipeRepository>())
      ..loadStats(widget.recipeId);
  }

  @override
  void dispose() {
    _statsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _statsCubit,
      child: BlocBuilder<ReviewStatsCubit, ReviewStatsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Padding(
              padding: EdgeInsets.all(48),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.orange,
                  strokeWidth: 2,
                ),
              ),
            );
          }
          if (state.isFailure || state.stats == null) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Không thể tải đánh giá',
                  style: TextStyle(color: Colors.black45),
                ),
              ),
            );
          }

          final stats = state.stats!;
          final reviews = stats.reviews ?? [];
          final previewReviews = reviews.take(3).toList();
          final hasMore = reviews.length >= 5;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RatingSummaryWidget(stats: stats),
              const SizedBox(height: 12),

              if (reviews.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.rate_review_outlined,
                          size: 48,
                          color: Colors.black26,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Chưa có đánh giá nào',
                          style: TextStyle(color: Colors.black45),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                const Text(
                  "Nhận xét của người dùng",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                ...previewReviews.map((review) => ReviewCard(review: review)),

                if (hasMore) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.allReviewPage,
                          arguments: {
                            'recipeId': widget.recipeId,
                            'recipeTitle': widget.recipeTitle,
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.rate_review_outlined,
                        size: 16,
                        color: Colors.orange,
                      ),
                      label: Text(
                        'Xem tất cả ${stats.totalReviews ?? reviews.length} đánh giá',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 13,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}
