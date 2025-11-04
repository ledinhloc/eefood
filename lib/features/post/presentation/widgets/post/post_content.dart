import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:eefood/features/post/presentation/widgets/post/post_card.dart';
import 'package:flutter/material.dart';
import '../../../data/models/post_model.dart';

class PostContent extends StatelessWidget {
  final PostModel post;
  const PostContent({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            post.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: kPrimaryColor,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),

          // Description (nếu có)
          if (post.description != null && post.description!.isNotEmpty) ...[
            Text(
              post.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Content
          Text(
            post.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),

          // Recipe Info Row (Region, Difficulty, Time)
          _buildRecipeInfoRow(),

          const SizedBox(height: 10),

          // Categories
          if (post.recipeCategories.isNotEmpty) ...[
            _buildCategoryChips(),
            const SizedBox(height: 8),
          ],

          // Ingredients Keywords
          if (post.recipeIngredientKeywords.isNotEmpty) ...[
            _buildIngredientsSection(),
            const SizedBox(height: 8),
          ],

          // Reaction Summary
          _buildReactionSummary(post.reactionCounts),
        ],
      ),
    );
  }

  Widget _buildRecipeInfoRow() {
    final hasInfo = post.region != null ||
        post.difficulty != null ||
        post.prepTime != null ||
        post.cookTime != null;

    if (!hasInfo) return const SizedBox.shrink();

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        // Region
        if (post.region != null && post.region!.isNotEmpty)
          _buildInfoChip(
            icon: Icons.place_outlined,
            label: post.region!,
            color: kSecondaryColor,
          ),

        // Difficulty
        if (post.difficulty != null && post.difficulty!.isNotEmpty)
          _buildInfoChip(
            icon: _getDifficultyIcon(post.difficulty!),
            label: post.difficulty!,
            color: _getDifficultyColor(post.difficulty!),
          ),

        // Prep Time
        if (post.prepTime != null && post.prepTime! > 0)
          _buildInfoChip(
            icon: Icons.timer_outlined,
            label: '${post.prepTime}p chuẩn bị',
            color: kAccentColor,
          ),

        // Cook Time
        if (post.cookTime != null && post.cookTime! > 0)
          _buildInfoChip(
            icon: Icons.local_fire_department_outlined,
            label: '${post.cookTime}p nấu',
            color: kPrimaryLight,
          ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
      case 'dễ':
        return Icons.sentiment_satisfied_alt;
      case 'medium':
      case 'trung bình':
        return Icons.sentiment_neutral;
      case 'hard':
      case 'khó':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.help_outline;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
      case 'dễ':
        return kSecondaryColor;
      case 'medium':
      case 'trung bình':
        return kAccentColor;
      case 'hard':
      case 'khó':
        return kPrimaryColor;
      default:
        return Colors.grey;
    }
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: post.recipeCategories.take(4).map((category) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryColor.withOpacity(0.8), kPrimaryLight],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            category,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 16,
              color: kSecondaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              'Nguyên liệu:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: post.recipeIngredientKeywords.take(5).map((ingredient) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: kNeutralLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kNeutralGray, width: 0.5),
              ),
              child: Text(
                ingredient,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReactionSummary(Map<ReactionType, int> reactionCounts) {
    // Lọc bỏ reaction có count = 0
    final filtered = reactionCounts.entries
        .where((e) => e.value > 0)
        .toList();

    filtered.sort((a, b) => b.value.compareTo(a.value));

    if (filtered.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: kNeutralLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: filtered.map((entry) {
          // Tìm emoji theo ReactionType
          final reaction = reactions.firstWhere(
                (r) => r.type == entry.key,
            orElse: () => ReactionOption(
              type: entry.key,
              emoji: '❓',
              color: Colors.grey,
            ),
          );
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Text(reaction.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 4),
                Text(
                  entry.value.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}