// features/recipe_review/presentation/pages/all_reviews_page.dart

import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/recipe_review/domain/repositories/review_recipe_repository.dart';
import 'package:eefood/features/recipe_review/presentation/provider/review_list_cubit.dart';
import 'package:eefood/features/recipe_review/presentation/widgets/list_review/review_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AllReviewsPage extends StatefulWidget {
  final int recipeId;
  final String recipeTitle;

  const AllReviewsPage({
    super.key,
    required this.recipeId,
    required this.recipeTitle,
  });

  @override
  State<AllReviewsPage> createState() => _AllReviewsPageState();
}

class _AllReviewsPageState extends State<AllReviewsPage> {
  late final ReviewListCubit _cubit;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _cubit = ReviewListCubit(repository: getIt<ReviewRecipeRepository>())
      ..loadInitial(widget.recipeId);

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _cubit.loadMore(widget.recipeId);
    }
  }

  Future<void> _onRefresh() async {
    await _cubit.refresh(widget.recipeId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Đánh giá",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Text(
                widget.recipeTitle,
                style: const TextStyle(fontSize: 12, color: Colors.black45),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        body: BlocBuilder<ReviewListCubit, ReviewListState>(
          builder: (context, state) {
            // Lần đầu loading
            if (state.status == ReviewListStatus.initial ||
                (state.status == ReviewListStatus.loadingMore &&
                    state.reviews.isEmpty)) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.orange,
                  strokeWidth: 2,
                ),
              );
            }

            // Lỗi và chưa có data
            if (state.status == ReviewListStatus.failure &&
                state.reviews.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.black26,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Không thể tải đánh giá',
                      style: TextStyle(color: Colors.black45),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => _cubit.loadInitial(widget.recipeId),
                      child: const Text(
                        'Thử lại',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Empty state
            if (state.reviews.isEmpty) {
              return RefreshIndicator(
                color: Colors.orange,
                onRefresh: _onRefresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 80),
                    Center(
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
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: Colors.orange,
              onRefresh: _onRefresh,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                physics: const AlwaysScrollableScrollPhysics(),
                // +1 nếu còn hasMore (footer spinner)
                itemCount: state.reviews.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // Footer spinner
                  if (index == state.reviews.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: state.isLoadingMore
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.orange,
                                strokeWidth: 2,
                              ),
                            )
                          : const SizedBox.shrink(),
                    );
                  }

                  return ReviewCard(review: state.reviews[index]);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
