import 'package:flutter/material.dart';
import 'package:eefood/features/post/data/models/comment_model.dart';
import 'package:eefood/features/post/presentation/provider/comment_list_cubit.dart';
import 'comment_item.dart';

class CommentItemReplies extends StatelessWidget {
  final CommentModel parent;
  final int depth;
  final bool showAllReplies;
  final VoidCallback onShowAll;
  final bool canShowMore;
  final CommentListCubit cubit;

  const CommentItemReplies({
    super.key,
    required this.parent,
    required this.depth,
    required this.showAllReplies,
    required this.onShowAll,
    required this.canShowMore,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    final replies = parent.replies ?? [];
    final visibleReplies =
        depth == 1 || showAllReplies ? replies : replies.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        for (final reply in visibleReplies)
          CommentItem(comment: reply, depth: depth + 1),
        if (canShowMore && (!showAllReplies))
          GestureDetector(
            onTap: () {
              onShowAll();
              cubit.fetchRepliesComment(parent.id!);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0, top: 4),
              child: Text(
                "Xem ${parent.replyCount! - (parent.replies?.length ?? 0)} phản hồi khác...",
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
