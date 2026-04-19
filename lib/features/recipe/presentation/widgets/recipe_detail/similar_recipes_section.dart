import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app_routes.dart';
import '../../../data/models/post_publish_model.dart';
import '../../provider/similar_recipes_cubit.dart';

class SimilarRecipesSection extends StatelessWidget {
  final int currentRecipeId;

  const SimilarRecipesSection({super.key, required this.currentRecipeId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SimilarRecipesCubit, SimilarRecipesState>(
      builder: (context, state) {
        final similarRecipes = state.recipes
            .where((post) => post.recipeId != currentRecipeId)
            .take(10)
            .toList();

        if (state.isLoading) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Món tương tự',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Center(child: CircularProgressIndicator()),
            ],
          );
        }

        if (similarRecipes.isEmpty && state.error == null) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Món tương tự',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Khám phá thêm 10 món gần giống với công thức này',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            if (similarRecipes.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 230,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: similarRecipes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final post = similarRecipes[index];
                    return _SimilarRecipeCard(post: post);
                  },
                ),
              ),
            ],
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
  final PostPublishModel post;

  const _SimilarRecipeCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
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
                    if ((post.difficulty ?? '').isNotEmpty)
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
                          post.difficulty!,
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
