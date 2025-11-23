import 'package:eefood/features/post/data/models/story_comment_model.dart';
import 'package:eefood/features/post/presentation/provider/story_comment_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'story_comment_item.dart';

class StoryCommentList extends StatefulWidget {
  final int? currentUserId;
  final Function(StoryCommentModel) onReply;
  final Function(StoryCommentModel) onEdit;
  final Function(int, {int? parentId}) onDelete;
  final ScrollController? scrollController;
  final int storyId;

  const StoryCommentList({
    super.key,
    this.currentUserId,
    required this.onReply,
    required this.onEdit,
    required this.onDelete,
    this.scrollController,
    required this.storyId
  });

  @override
  State<StoryCommentList> createState() => _StoryCommentListState();
}

class _StoryCommentListState extends State<StoryCommentList> {
  late ScrollController _scrollController;
  late StoryCommentCubit _commentCubit;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _commentCubit = context.read<StoryCommentCubit>();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (widget.storyId != null) {
        _commentCubit.loadComments(widget.storyId, loadMore: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryCommentCubit, StoryCommentState>(
      builder: (context, state) {
        if (state.isLoading && state.comments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.comments.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 50,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Chưa có bình luận nào.\nHãy là người đầu tiên bình luận!',
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: state.comments.length + (state.isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.comments.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final comment = state.comments[index];
            final replyCount = state.replyCountCache[comment.id] ?? 0;
            final isExpanded = state.expandedReplies.contains(comment.id);
            final isLoadingReplies = state.isLoadingReplies[comment.id] == true;
            final repliesPage = state.repliesCache[comment.id];
            final replies = isExpanded && repliesPage != null
                ? repliesPage.viewers
                : <StoryCommentModel>[];

            return Column(
              children: [
                CommentStoryItem(
                  comment: comment,
                  currentUserId: widget.currentUserId,
                  replyCount: replyCount,
                  isExpanded: isExpanded,
                  onReply: () => widget.onReply(comment),
                  onUpdate: () => widget.onEdit(comment),
                  onDelete: () => widget.onDelete(comment.id!),
                  onLoadReplies: replyCount > 0
                      ? () => _commentCubit.toggleReplies(comment.id!)
                      : null,
                ),

                // Loading indicator for replies
                if (isLoadingReplies)
                  const Padding(
                    padding: EdgeInsets.only(left: 46, top: 8, bottom: 8),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),

                // Display replies
                if (isExpanded && replies.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 46),
                    child: Column(
                      children: replies.map((reply) {
                        return CommentStoryItem(
                          comment: reply,
                          currentUserId: widget.currentUserId,
                          onUpdate: () => widget.onEdit(reply),
                          onDelete: () =>
                              widget.onDelete(reply.id!, parentId: comment.id),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
