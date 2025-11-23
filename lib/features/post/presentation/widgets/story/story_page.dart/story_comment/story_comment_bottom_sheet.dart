import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/post/data/models/story_comment_model.dart';
import 'package:eefood/features/post/presentation/provider/story_comment_cubit.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_page.dart/story_comment/story_comment_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'story_comment_list.dart';

class StoryCommentBottomSheet extends StatefulWidget {
  final int? storyId;
  final int? currentUserId;

  const StoryCommentBottomSheet({
    super.key,
    required this.storyId,
    this.currentUserId,
  });

  @override
  State<StoryCommentBottomSheet> createState() =>
      _StoryCommentBottomSheetState();
}

class _StoryCommentBottomSheetState extends State<StoryCommentBottomSheet> {
  late StoryCommentCubit _commentCubit;

  StoryCommentModel? _replyingTo;
  StoryCommentModel? _editingComment;
  late FocusNode _inputFocusNode;

  @override
  void initState() {
    super.initState();
    _commentCubit = context.read<StoryCommentCubit>();
    _inputFocusNode = FocusNode();
    if (widget.storyId != null) {
      _commentCubit.loadComments(widget.storyId!);
    }
  }

  Future<void> _deleteComment(int commentId, {int? parentId}) async {
    try {
      await _commentCubit.deleteComment(commentId, parentId: parentId);

      if (parentId != null) {
        await _commentCubit.reloadReplies(parentId);
      }
      _commentCubit.loadComments(widget.storyId!);

      _inputFocusNode.unfocus();

      showCustomSnackBar(context, 'Đã xóa bình luận');
    } catch (e) {
      showCustomSnackBar(context, 'Không thể xóa bình luận');
    }
  }

  void _startReply(StoryCommentModel comment) {
    setState(() {
      _replyingTo = comment;
      _editingComment = null;
    });
  }

  void _startEdit(StoryCommentModel comment) {
    setState(() {
      _editingComment = comment;
      _replyingTo = null;
    });
  }

  void _cancelAction() {
    setState(() {
      _replyingTo = null;
      _editingComment = null;
    });

    _inputFocusNode.unfocus();
  }

  void _onActionCompleted(StoryCommentModel? comment) {
    setState(() {
      _replyingTo = null;
      _editingComment = null;
    });

    _inputFocusNode.unfocus();
  }

  @override
  void dispose() {
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                BlocBuilder<StoryCommentCubit, StoryCommentState>(
                  builder: (context, state) {
                    return Text(
                      'Bình luận (${state.totalElements})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Comment List
          Expanded(
            child: StoryCommentList(
              currentUserId: widget.currentUserId,
              onReply: _startReply,
              onEdit: _startEdit,
              onDelete: _deleteComment,
              storyId: widget.storyId!,
            ),
          ),

          // Comment Input
          StoryCommentInput(
            storyId: widget.storyId,
            replyingTo: _replyingTo,
            editingComment: _editingComment,
            onCancelAction: _cancelAction,
            onActionCompleted: _onActionCompleted,
            focusNode: _inputFocusNode,
          ),
        ],
      ),
    );
  }
}
