import 'package:eefood/core/utils/reaction_helper.dart';
import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CommentReactionSummary extends StatelessWidget {
  final Map<ReactionType, int> reactionCounts;

  const CommentReactionSummary({super.key, required this.reactionCounts});

  @override
  Widget build(BuildContext context) {
    print(reactionCounts.length);
    final filteredReactions = reactionCounts.entries
        .where((entry) => entry.value > 0)
        .toList();

    if (filteredReactions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sắp xếp theo số lượng giảm dần
    filteredReactions.sort((a, b) => b.value.compareTo(a.value));

    // Lấy top 3 reaction phổ biến nhất
    final topReactions = filteredReactions.take(3).toList();
    final totalCount = filteredReactions.fold(
      0,
      (sum, entry) => sum + entry.value,
    );

    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hiển thị các icon reaction
            ...topReactions.asMap().entries.map((entry) {
              final index = entry.key;
              final reaction = entry.value;
              final reactionEmoji = ReactionHelper.emoji(reaction.key);

              return Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: index * 8.0),
                    child: Text(
                      reactionEmoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(width: 4),

            // Hiển thị tổng số reaction
            Text(
              totalCount.toString(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
