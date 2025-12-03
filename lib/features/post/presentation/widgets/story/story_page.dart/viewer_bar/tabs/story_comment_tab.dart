import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/post/data/models/story_comment_model.dart';
import 'package:eefood/features/post/presentation/provider/story_comment_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../story_comment/story_comment_input.dart';
import '../../story_comment/story_comment_list.dart';

class StoryCommentTab extends StatefulWidget {
  final int storyId;
  final int? currentUserId;

  const StoryCommentTab({super.key, required this.storyId, this.currentUserId});

  @override
  State<StoryCommentTab> createState() => _StoryCommentTabState();
}

class _StoryCommentTabState extends State<StoryCommentTab>
    with AutomaticKeepAliveClientMixin {
  late StoryCommentCubit _commentCubit;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();

  StoryCommentModel? _replyingTo;
  StoryCommentModel? _editingComment;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _commentCubit = getIt<StoryCommentCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _commentCubit.loadComments(widget.storyId);
    });

    _inputFocusNode.addListener(() {
      if (_inputFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && _scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _deleteComment(int commentId, {int? parentId}) async {
    try {
      await _commentCubit.deleteComment(commentId);

      if (parentId != null) {
        await _commentCubit.reloadReplies(parentId);
      }

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
  }

  void _onActionCompleted(StoryCommentModel? comment) {
    setState(() {
      _replyingTo = null;
      _editingComment = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocProvider.value(
      value: _commentCubit,
      child: Column(
        children: [
          // Comment List
          Expanded(
            child: StoryCommentList(
              currentUserId: widget.currentUserId,
              onReply: _startReply,
              onEdit: _startEdit,
              onDelete: _deleteComment,
              storyId: widget.storyId,
              scrollController: _scrollController,
            ),
          ),

          // Comment Input 
          StoryCommentInput(
            storyId: widget.storyId,
            replyingTo: _replyingTo,
            editingComment: _editingComment,
            onCancelAction: _cancelAction,
            onActionCompleted: _onActionCompleted,
          ),
        ],
      ),
    );
  }
}
