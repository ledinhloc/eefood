import 'package:cached_network_image/cached_network_image.dart';
import 'package:eefood/app_routes.dart';
import 'package:eefood/features/post/data/models/post_model.dart';
import 'package:flutter/material.dart';

class PostMessageCard extends StatelessWidget {
  final PostModel postModel;
  const PostMessageCard({super.key, required this.postModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.recipeDetail,
          arguments: {'recipeId': postModel.recipeId},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        // Column phải là children có thể co giãn → dùng chiều cao từ Grid
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: CachedNetworkImage(
                imageUrl: postModel.imageUrl,
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  height: 110,
                  color: Colors.grey.shade100,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.grey.shade400,
                    size: 32,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TITLE
                  Text(
                    postModel.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:  TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  // META CHIPS
                  _buildMeta(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeta() {
    final hasPrepTime = postModel.prepTime != null;
    final hasDifficulty = postModel.difficulty != null;

    if (!hasPrepTime && !hasDifficulty) return const SizedBox.shrink();

    return Row(
      children: [
        if (hasPrepTime)
          _MetaChip(
            icon: Icons.access_time_rounded,
            label: '${postModel.prepTime}p',
          ),
        if (hasPrepTime && hasDifficulty) const SizedBox(width: 6),
        if (hasDifficulty)
          Flexible(
            child: _MetaChip(
              icon: Icons.bar_chart_rounded,
              label: postModel.difficulty!,
            ),
          ),
      ],
    );
  }
}

/// Widget nhỏ hiển thị icon + text meta, tự co lại nếu text dài
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.deepOrange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.deepOrange),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.deepOrange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
