import 'package:flutter/material.dart';
import 'package:eefood/core/utils/convert_time.dart';
import 'package:eefood/features/post/data/models/comment_model.dart';
import 'package:eefood/features/post/presentation/provider/comment_list_cubit.dart';

class CommentItemActions extends StatelessWidget {
  final CommentModel comment;
  final int depth;
  final GlobalKey actionButtonKey;
  final CommentListCubit cubit;
  final Function(BuildContext) showReactionPopup;

  const CommentItemActions({
    super.key,
    required this.comment,
    required this.depth,
    required this.actionButtonKey,
    required this.cubit,
    required this.showReactionPopup,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          TimeParser.formatCommentTime(comment.createdAt),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          key: actionButtonKey,
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onTap: () => showReactionPopup(context),
          child: Text(
            "Thích",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 16),
        if (depth < 3)
          GestureDetector(
            onTap: () => cubit.setReplyingTo(comment),
            child: Text(
              "Trả lời",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
