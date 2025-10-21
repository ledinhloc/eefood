import 'package:eefood/core/utils/reaction_helper.dart';
import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:eefood/features/post/presentation/provider/comment_list_state.dart';
import 'package:eefood/features/post/presentation/widgets/comment/comment_item/reaction_animation.dart';
import 'package:eefood/features/post/presentation/widgets/post/reaction_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eefood/features/post/data/models/comment_model.dart';
import 'package:eefood/features/post/presentation/provider/comment_list_cubit.dart';
import 'comment_item_content.dart';
import 'comment_item_replies.dart';

class CommentItem extends StatefulWidget {
  final CommentModel comment;
  final int depth;

  const CommentItem({super.key, required this.comment, this.depth = 1});

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool _isExpanded = false;
  bool _showAllReplies = false;
  final GlobalKey _actionButtonKey = GlobalKey();

  bool get _shouldShowExpanded => widget.depth == 1 || _isExpanded;
  bool get _hasReplies => widget.comment.replies?.isNotEmpty == true;
  bool get _hasMoreReplies =>
      widget.comment.replyCount != null &&
      (widget.comment.replies?.length ?? 0) < widget.comment.replyCount!;
  bool get _canShowMoreReplies => _hasMoreReplies && widget.depth < 3;

  void _toggleExpand() => setState(() => _isExpanded = !_isExpanded);
  void _showAll() => setState(() => _showAllReplies = true);

  void _showFlyingReaction(Offset position, ReactionType type) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final entry = OverlayEntry(
      builder: (_) => ReactionAnimation(
        emoji: ReactionHelper.emoji(type),
        startPosition: position,
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(milliseconds: 1200), () {
      entry.remove();
    });
  }

  void _handleReact(ReactionType? newReaction) async {
    final cubit = context.read<CommentListCubit>();

    final RenderBox? box =
        _actionButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final Offset position = box?.localToGlobal(Offset.zero) ?? Offset.zero;

    final currentReaction = widget.comment.currentUserReaction;

    // Nếu chọn lại reaction hiện tại -> xóa reaction
    if (newReaction == currentReaction) {
      await cubit.removeReaction(widget.comment.id!);
    } else {
      // Nếu chọn reaction khác -> hiện hiệu ứng và cập nhật reaction
      if (newReaction != null) {
        _showFlyingReaction(position, newReaction);
      }
      await cubit.reactToComment(widget.comment.id!, newReaction!);
    }
  }

  CommentModel? _findCommentInTree(List<CommentModel> list, int id) {
    for (final c in list) {
      if (c.id == id) return c;
      if (c.replies != null && c.replies!.isNotEmpty) {
        final found = _findCommentInTree(c.replies!, id);
        if (found != null) return found;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    print(
      'Building CommentItem id: ${widget.comment.id}, reaction: ${widget.comment.currentUserReaction}',
    );
    return BlocConsumer<CommentListCubit, CommentListState>(
      listener: (context, state) {
        print(
          'BlocConsumer listener - replyingTo: ${state.replyingTo?.id}, replyKey: ${state.replyKey}',
        );
      },
      builder: (context, state) {
        final cubit = context.read<CommentListCubit>();

        final updatedComment =
            _findCommentInTree(state.comments, widget.comment.id ?? -1) ??
            widget.comment;

        return Container(
          key: ValueKey(
            'comment_${updatedComment.id}_${updatedComment.currentUserReaction ?? "none"}_${updatedComment.reactionCounts?.toString() ?? "no_counts"}',
          ),
          margin: EdgeInsets.only(
            left: (widget.depth - 1) * 16.0,
            top: 4,
            bottom: 4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar + Content
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage:
                        (updatedComment.avatarUrl != null &&
                            updatedComment.avatarUrl!.isNotEmpty)
                        ? NetworkImage(updatedComment.avatarUrl!)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.depth > 1 && !_shouldShowExpanded
                          ? _toggleExpand
                          : null,
                      child: CommentItemContent(
                        comment: updatedComment, // Sử dụng comment đã cập nhật
                        depth: widget.depth,
                        shouldShowExpanded: _shouldShowExpanded,
                        onExpand: _toggleExpand,
                        actionButtonKey: _actionButtonKey,
                        cubit: cubit,
                        showReactionPopup: (ctx) =>
                            showReactionPopup(ctx, _actionButtonKey),
                      ),
                    ),
                  ),
                ],
              ),

              // Replies section
              if (_shouldShowExpanded && _hasReplies)
                CommentItemReplies(
                  parent: updatedComment, // Sử dụng comment đã cập nhật
                  depth: widget.depth,
                  showAllReplies: _showAllReplies,
                  onShowAll: _showAll,
                  canShowMore: _canShowMoreReplies,
                  cubit: cubit,
                ),

              // Hiển thị "Xem thêm phản hồi" khi collapsed (chỉ depth > 1)
              if (!_shouldShowExpanded && _hasReplies && widget.depth > 1)
                GestureDetector(
                  onTap: _toggleExpand,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24, top: 4),
                    child: Text(
                      "Xem thêm ${updatedComment.replyCount ?? updatedComment.replies?.length ?? 0} phản hồi",
                      style: const TextStyle(fontSize: 13, color: Colors.blue),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void showReactionPopup(BuildContext context, GlobalKey key) {
    final renderObject = key.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return;

    final renderBox = renderObject as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              left: offset.dx - 30,
              top: offset.dy - 80,
              child: ReactionPopup(
                onSelect: (reaction) {
                  Navigator.of(context).pop();
                  _handleReact(reaction);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
