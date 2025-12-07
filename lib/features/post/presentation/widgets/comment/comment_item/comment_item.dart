import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/reaction_helper.dart';
import 'package:eefood/core/widgets/custom_bottom_sheet.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eefood/features/post/data/models/comment_model.dart';
import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:eefood/features/post/presentation/provider/comment_list_cubit.dart';
import 'package:eefood/features/post/presentation/provider/comment_list_state.dart';
import 'package:eefood/features/post/presentation/widgets/comment/comment_item/reaction_animation.dart';
import 'package:eefood/features/post/presentation/widgets/post/reaction_popup.dart';
import 'package:eefood/features/report/presentation/widgets/report_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'comment_item_content.dart';
import 'comment_item_replies.dart';

class CommentItem extends StatefulWidget {
  final CommentModel comment;
  final VoidCallback? onDeleted;
  final Function(String)? onEdit;
  final int depth;

  const CommentItem({
    super.key,
    required this.comment,
    this.onDeleted,
    this.onEdit,
    this.depth = 1,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  final GetCurrentUser _getCurrentUser = getIt<GetCurrentUser>();
  bool _isExpanded = false;
  bool _showAllReplies = false;
  final GlobalKey _actionButtonKey = GlobalKey();

  bool get _shouldShowExpanded => widget.depth == 1 || _isExpanded;
  bool get _hasReplies => widget.comment.replies?.isNotEmpty == true;
  bool get _hasMoreReplies =>
      (widget.comment.replyCount ?? 0) > (widget.comment.replies?.length ?? 0);
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
    Future.delayed(const Duration(milliseconds: 1200), entry.remove);
  }

  Future<void> _handleReact(ReactionType? newReaction) async {
    final cubit = context.read<CommentListCubit>();
    final box =
        _actionButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final position = box?.localToGlobal(Offset.zero) ?? Offset.zero;

    final currentReaction = widget.comment.currentUserReaction;
    if (newReaction == currentReaction) {
      await cubit.removeReaction(widget.comment.id!);
    } else if (newReaction != null) {
      _showFlyingReaction(position, newReaction);
      await cubit.reactToComment(widget.comment.id!, newReaction);
    }
  }

  CommentModel? _findCommentInState(
    List<CommentModel> comments,
    int commentId,
  ) {
    for (final comment in comments) {
      if (comment.id == commentId) {
        return comment;
      }
      if (comment.replies != null && comment.replies!.isNotEmpty) {
        final found = _findCommentInState(comment.replies!, commentId);
        if (found != null) return found;
      }
    }
    return null;
  }

  void _copyContent(String text) {
    Clipboard.setData(ClipboardData(text: text));
    showCustomSnackBar(context, "Sao chép thành công");
  }

  Future<String?> _showEditDialog(String initialText) {
    final controller = TextEditingController(text: initialText);
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Chỉnh sửa bình luận"),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: "Nhập nội dung mới...",
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  void _showOptions() async {
    final user = await _getCurrentUser();
    print(user?.id);
    print(widget.comment.userId);

    final options = <BottomSheetOption>[
      // Nếu comment thuộc về user hiện tại thì hiển thị các tùy chọn này
      if (widget.comment.userId == user?.id) ...[
        BottomSheetOption(
          icon: const Icon(Icons.delete, color: Colors.red),
          title: "Xóa bình luận",
          onTap: () {
            if (widget.onDeleted != null) {
              widget.onDeleted!();
            }
          },
        ),
        if (widget.comment.images?.isEmpty == true &&
            widget.comment.videos?.isEmpty == true)
          BottomSheetOption(
            icon: const Icon(Icons.edit, color: Colors.orange),
            title: "Chỉnh sửa",
            onTap: () async {
              final newContent = await _showEditDialog(
                widget.comment.content ?? '',
              );
              if (newContent?.isNotEmpty == true) {
                widget.onEdit?.call(newContent!);
              }
            },
          ),
      ],
      BottomSheetOption(
        icon: const Icon(Icons.report, color: Colors.yellowAccent),
        title: "Báo cáo bài viết",
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => ReportBottomSheet(
              targerId: widget.comment.id!,
              targetTitle: widget.comment.username,
              type: 'COMMENT',
            ),
          );
        },
      ),
      // Tùy chọn sao chép nội dung (luôn có)
      BottomSheetOption(
        icon: const Icon(Icons.copy, color: Colors.grey),
        title: "Sao chép nội dung",
        onTap: () => _copyContent(widget.comment.content ?? ""),
      ),
    ];

    await showCustomBottomSheet(context, options);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommentListCubit, CommentListState>(
      listener: (context, state) {},
      builder: (context, state) {
        final cubit = context.read<CommentListCubit>();
        final updated =
            _findCommentInState(state.comments, widget.comment.id ?? -1) ??
            widget.comment;

        if (updated == null) {
          return const SizedBox.shrink();
        }

        return Container(
          key: ValueKey(
            'comment_${updated.id}_${updated.currentUserReaction ?? "none"}_${updated.reactionCounts ?? "no_counts"}',
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
                    backgroundImage: (updated.avatarUrl?.isNotEmpty ?? false)
                        ? NetworkImage(updated.avatarUrl!)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onLongPress: _showOptions,
                      onTap: widget.depth > 1 && !_shouldShowExpanded
                          ? _toggleExpand
                          : null,
                      child: CommentItemContent(
                        comment: updated,
                        depth: widget.depth,
                        shouldShowExpanded: _shouldShowExpanded,
                        onExpand: _toggleExpand,
                        actionButtonKey: _actionButtonKey,
                        cubit: cubit,
                        showReactionPopup: (ctx) => _showReactionPopup(ctx),
                      ),
                    ),
                  ),
                ],
              ),

              // Replies
              if (_shouldShowExpanded && _hasReplies)
                CommentItemReplies(
                  parent: updated,
                  depth: widget.depth,
                  showAllReplies: _showAllReplies,
                  onShowAll: _showAll,
                  canShowMore: _canShowMoreReplies,
                  cubit: cubit,
                ),

              // Xem thêm phản hồi
              if (!_shouldShowExpanded && _hasReplies && widget.depth > 1)
                GestureDetector(
                  onTap: _toggleExpand,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24, top: 4),
                    child: Text(
                      "Xem thêm ${updated.replyCount ?? updated.replies?.length ?? 0} phản hồi",
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

  void _showReactionPopup(BuildContext context) {
    final renderBox =
        _actionButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(Offset.zero);

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: offset.dx - 30,
            top: offset.dy - 80,
            child: ReactionPopup(
              onSelect: (reaction) {
                Navigator.pop(context);
                _handleReact(reaction);
              },
            ),
          ),
        ],
      ),
    );
  }
}
