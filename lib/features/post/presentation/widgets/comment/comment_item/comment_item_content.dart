import 'package:eefood/core/utils/reaction_helper.dart';
import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:eefood/features/post/presentation/widgets/comment/comment_item/comment_reaction_summary.dart';
import 'package:flutter/material.dart';
import 'package:eefood/core/utils/convert_time.dart';
import 'package:eefood/features/post/data/models/comment_model.dart';
import 'package:eefood/features/post/presentation/provider/comment_list_cubit.dart';
import 'comment_item_actions.dart';
import '../comment_media.dart';

class CommentItemContent extends StatelessWidget {
  final CommentModel comment;
  final int depth;
  final bool shouldShowExpanded;
  final VoidCallback onExpand;
  final GlobalKey actionButtonKey;
  final CommentListCubit cubit;
  final Function(BuildContext) showReactionPopup;

  const CommentItemContent({
    super.key,
    required this.comment,
    required this.depth,
    required this.shouldShowExpanded,
    required this.onExpand,
    required this.actionButtonKey,
    required this.cubit,
    required this.showReactionPopup,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            comment.username ?? "Người dùng ẩn danh",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 4),
          shouldShowExpanded
              ? _buildExpanded()
              : _buildCollapsed(context, onExpand),
          const SizedBox(height: 4),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildExpanded() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (comment.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(comment.content, style: const TextStyle(fontSize: 14)),
          ),
        if (comment.images?.isNotEmpty == true ||
            comment.videos?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: CommentMedia(
              images: comment.images ?? [],
              videos: comment.videos ?? [],
            ),
          ),
      ],
    );
  }

  Widget _buildCollapsed(BuildContext context, VoidCallback onExpand) {
    return GestureDetector(
      onTap: onExpand,
      child: Text(
        comment.content.length > 100
            ? '${comment.content.substring(0, 100)}...'
            : comment.content,
        style: const TextStyle(fontSize: 14),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Luôn hiển thị Like + Reply
  Widget _buildActions(BuildContext context) {
    final hasCurrentReaction = comment.currentUserReaction != null;
    final currentUserReaction = comment.currentUserReaction;

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
          onTapDown: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onTap: () => showReactionPopup(context),
          child: Row(
            children: [
              Text(
                hasCurrentReaction
                    ? ReactionHelper.label(currentUserReaction!)
                    : "Thích",
                style: TextStyle(
                  fontSize: 12,
                  color: hasCurrentReaction
                      ? ReactionHelper.color(currentUserReaction!)
                      : Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (depth < 3) ...[
          const SizedBox(width: 16),
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
      ],
    );
  }
}
