import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app_routes.dart';
import '../../../data/models/similar_post_model.dart';
import '../../provider/similar_recipes_cubit.dart';
import 'similar_recipe_ingredient_filter.dart';

class SimilarRecipesSection extends StatelessWidget {
  static const double _recipesListHeight = 230;

  final int currentRecipeId;
  final List<String> availableIngredients;

  const SimilarRecipesSection({
    super.key,
    required this.currentRecipeId,
    required this.availableIngredients,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SimilarRecipesCubit, SimilarRecipesState>(
      builder: (context, state) {
        final similarRecipes = state.recipes
            .where((post) => post.recipeId != currentRecipeId)
            .take(10)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SimilarRecipeIngredientFilter(
              currentRecipeId: currentRecipeId,
              availableIngredients: availableIngredients,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: _recipesListHeight,
              width: double.infinity,
              child: state.isLoading
                  ? const _SimilarRecipeSkeletonList()
                  : similarRecipes.isNotEmpty
                  ? ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: similarRecipes.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final post = similarRecipes[index];
                        return _SimilarRecipeCard(post: post);
                      },
                    )
                  : const _EmptySimilarRecipesCard(),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 8),
              Text(
                'Không thể tải gợi ý món tương tự: ${state.error}',
                style: TextStyle(color: Colors.red.shade400, fontSize: 12),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SimilarRecipeCard extends StatelessWidget {
  final SimilarPostModel post;

  const _SimilarRecipeCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          if (post.recipeId == null) return;
          Navigator.pushNamed(
            context,
            AppRoutes.recipeDetail,
            arguments: {'recipeId': post.recipeId},
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: post.imageUrl != null && post.imageUrl!.isNotEmpty
                    ? Image.network(
                        post.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const _SimilarPlaceholder(),
                      )
                    : const _SimilarPlaceholder(),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (post.matchedIngredients.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          post.matchedIngredients.take(2).join(', '),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySimilarRecipesCard extends StatelessWidget {
  const _EmptySimilarRecipesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 42, color: Colors.orange.shade300),
          const SizedBox(height: 12),
          const Text(
            'Chưa có món phù hợp với lựa chọn hiện tại.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Thử chọn nguyên liệu khác để tìm thêm gợi ý.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _SimilarRecipeSkeletonList extends StatelessWidget {
  const _SimilarRecipeSkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (context, index) => const _SimilarRecipeSkeletonCard(),
    );
  }
}

class _SimilarRecipeSkeletonCard extends StatelessWidget {
  const _SimilarRecipeSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.orange.shade50,
                alignment: Alignment.center,
                child: Icon(
                  Icons.restaurant_menu,
                  size: 38,
                  color: Colors.orange.shade200,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBlock(width: double.infinity, height: 14),
                  const SizedBox(height: 8),
                  const _SkeletonBlock(width: 118, height: 14),
                  const SizedBox(height: 12),
                  _SkeletonBlock(width: 86, height: 22, radius: 999),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _SkeletonBlock({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _SimilarPlaceholder extends StatelessWidget {
  const _SimilarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange.shade50,
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant_menu,
        size: 42,
        color: Colors.orange.shade300,
      ),
    );
  }
}
