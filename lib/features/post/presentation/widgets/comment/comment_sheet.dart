import 'package:eefood/features/post/data/models/comment_model.dart';
import 'package:eefood/features/post/presentation/provider/comment_list_cubit.dart';
import 'package:eefood/features/post/presentation/provider/comment_list_state.dart';
import 'package:eefood/features/post/presentation/widgets/comment/comment_input.dart';
import 'package:eefood/features/post/presentation/widgets/comment/comment_item/comment_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentBottomSheet extends StatefulWidget {
  final int postId;
  const CommentBottomSheet({super.key, required this.postId});

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final _scrollController = ScrollController();
  late CommentListCubit? _cubit;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() => _onScroll(context));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cubit = context.read<CommentListCubit>();
  }

  void _onScroll(BuildContext context) {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _cubit?.fetchComments(widget.postId, loadMore: true);
    }
  }

  @override
  void didUpdateWidget(CommentBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu postId thay đổi, fetch comments mới và reset state
    if (oldWidget.postId != widget.postId) {
      _cubit?.resetForNewPost();
      _cubit?.fetchComments(widget.postId);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(left: 10, top: 5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Bình luận',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentList() {
    return BlocBuilder<CommentListCubit, CommentListState>(
      builder: (context, state) {
        if (state.isLoading && state.comments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.errorMessage != null && state.comments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.errorMessage}'),
                ElevatedButton(
                  onPressed: () => context
                      .read<CommentListCubit>()
                      .fetchComments(widget.postId),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          key: ValueKey(
            'comment_list_${state.comments.length}_${DateTime.now().millisecondsSinceEpoch}',
          ),
          controller: _scrollController,
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: state.comments.length + (state.isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.comments.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final comment = state.comments[index];

            return CommentItem(comment: comment, depth: 1);
          },
        );
      },
    );
  }

  Widget _buildCommentInput() {
    return BlocConsumer<CommentListCubit, CommentListState>(
      listener: (context, state) {
        // Listener để xử lý các state changes
        print(
          'BlocConsumer listener - replyingTo: ${state.replyingTo?.id}, replyKey: ${state.replyKey}',
        );
      },
      builder: (context, state) {
        return CommentInput(
          key: ValueKey(
            'comment_input_${state.replyingTo?.id}_${state.replyKey}_${state.isSubmitting}',
          ),
          isSubmitting: state.isSubmitting,
          replyingTo: state.replyingTo,
          onCancelReply: () {
            print('onCancelReply called');
            _cubit?.cancelReply();
          },
          onSubmit: (content, images, videos) {
            _cubit?.submitComment(
              postId: widget.postId,
              content: content,
              parentId: state.replyingTo?.id,
              images: images,
              videos: videos,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _cubit?.resetForNewPost();
                return _cubit?.fetchComments(widget.postId);
              },
              child: _buildCommentList(),
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }
}
