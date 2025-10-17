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
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(height: 6,),
          Text(
            post.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade700, height: 1.4),
          ),
          const SizedBox(height: 6,),
          _buildReactionSummary(post.reactionCounts),
        ],
      ),
    );
  }

  Widget _buildReactionSummary(Map<ReactionType, int> reactionCounts) {
    // Lọc bỏ reaction có count = 0
    final filtered = reactionCounts.entries
        .where((e) => e.value > 0)
        .toList();

    // Sắp xếp theo số lượng giảm dần
    filtered.sort((a, b) => b.value.compareTo(a.value));

    if (filtered.isEmpty) {
      return const SizedBox.shrink(); // không hiển thị nếu trống
    }

    // Trả về hàng emoji + số lượng
    return Padding(
      padding: const EdgeInsets.only(top: 6),
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
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                Text(reaction.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 4),
                Text(
                  entry.value.toString(),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

}
