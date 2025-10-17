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

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CommentListCubit>();

    return Container(
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
                backgroundImage: NetworkImage(widget.comment.avatarUrl ?? ''),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: widget.depth > 1 && !_shouldShowExpanded
                      ? _toggleExpand
                      : null,
                  child: CommentItemContent(
                    comment: widget.comment,
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
              parent: widget.comment,
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
                  "Xem thêm ${widget.comment.replyCount ?? widget.comment.replies?.length ?? 0} phản hồi",
                  style: const TextStyle(fontSize: 13, color: Colors.blue),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void showReactionPopup(BuildContext context, GlobalKey key) {
    final RenderBox renderBox =
        key.currentContext?.findRenderObject() as RenderBox;
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
              left: offset.dx - 10,
              top: offset.dy - 80,
              child: ReactionPopup(
                onSelect: (reaction) => Navigator.of(context).pop(),
              ),
            ),
          ],
        );
      },
    );
  }
}
