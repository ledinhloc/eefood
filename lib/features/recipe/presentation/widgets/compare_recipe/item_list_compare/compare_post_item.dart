import 'package:eefood/features/post/data/models/post_model.dart';
import 'package:eefood/features/recipe/presentation/widgets/compare_recipe/item_list_compare/difficulty_chip.dart';
import 'package:flutter/material.dart';

class ComparePostItem extends StatelessWidget {
  final PostModel post;
  final bool isSelected;
  final bool isCurrent;
  final VoidCallback? onSelect;
  const ComparePostItem({
    super.key,
    required this.post,
    required this.isSelected,
    required this.isCurrent,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onSelect,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: _cardColor(),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _borderColor(),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF2C9E6E).withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              _buildImage(),
              const SizedBox(width: 12),
              _buildInfo(),
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(13),
        bottomLeft: Radius.circular(13),
      ),
      child: Stack(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: post.imageUrl.isNotEmpty
                ? Image.network(
                    post.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
          ),
          // "Đang xem" overlay
          if (isCurrent)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.55),
                child: const Center(
                  child: Text(
                    'Đang\nxem',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isCurrent
                    ? const Color(0xFFAAAAAA)
                    : const Color(0xFF1A1A1A),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                if (post.region != null && post.region!.isNotEmpty) ...[
                  Icon(
                    Icons.location_on_rounded,
                    size: 10,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    post.region!,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                  const SizedBox(width: 8),
                ],
                if (post.difficulty != null) ...[
                  DifficultyChip(difficulty: post.difficulty!),
                ],
              ],
            ),
            if (post.prepTime != null || post.cookTime != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 10,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    _formatTime((post.prepTime ?? 0) + (post.cookTime ?? 0)),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: isCurrent
            ? const SizedBox(width: 36)
            : isSelected
            ? Container(
                key: const ValueKey('selected'),
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFF2C9E6E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              )
            : Container(
                key: const ValueKey('unselected'),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EDEA),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFDDDAD5)),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Color(0xFF888888),
                  size: 18,
                ),
              ),
      ),
    );
  }

  Color _cardColor() {
    if (isCurrent) return const Color(0xFFF5F3F0);
    if (isSelected) return const Color(0xFFF0FBF6);
    return Colors.white;
  }

  Color _borderColor() {
    if (isSelected) return const Color(0xFF2C9E6E);
    return const Color(0xFFEDEAE5);
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFF0EDEA),
      child: const Icon(Icons.restaurant_rounded, color: Colors.grey, size: 28),
    );
  }

  String _formatTime(int minutes) {
    if (minutes == 0) return '-';
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h${m}m';
  }
}
