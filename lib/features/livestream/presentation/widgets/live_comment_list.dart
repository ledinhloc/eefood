import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/live_comment_response.dart';
import '../provider/live_comment_cubit.dart';
import '../provider/live_comment_state.dart';
import 'live_comment_item.dart';

class LiveCommentList extends StatelessWidget {
  final TextEditingController controller;
  final ScrollController scrollController;
  final bool isStreamer;
  final Color inputBackgroundColor;

  const LiveCommentList({
    Key? key,
    required this.controller,
    required this.scrollController,
    this.isStreamer = false,
    this.inputBackgroundColor = const Color(0x4D000000),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Build comment list dựa trên role
    return isStreamer
        ? _buildStreamerCommentList(context)
        : _buildViewerCommentList(context);
  }

  Widget _buildViewerCommentList(BuildContext context) {
    return BlocBuilder<LiveCommentCubit, LiveCommentState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return _buildCommentUI(
          comments: state.comments,
          onSend: () {
            final text = controller.text.trim();
            if (text.isEmpty) return;

            context.read<LiveCommentCubit>().sendComment(text);
            controller.clear();
            _scrollToBottom();
          },
        );
      },
    );
  }

  Widget _buildStreamerCommentList(BuildContext context) {
    return BlocBuilder<LiveCommentCubit, LiveCommentState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return _buildCommentUI(
          comments: state.comments,
          onSend: () {
            final text = controller.text.trim();
            if (text.isEmpty) return;
            context.read<LiveCommentCubit>().sendComment(text);
            controller.clear();
            _scrollToBottom();
          },
        );
      },
    );
  }

  Widget _buildCommentUI({
    required List<LiveCommentResponse> comments,
    required VoidCallback onSend,
  }) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            reverse: true, // Reverse để comment mới nhất ở dưới
            itemCount: comments.length,
            itemBuilder: (context, index) {
              // Đảo ngược index vì reverse = true
              final comment = comments[comments.length - 1 - index];
              return LiveCommentItem(comment: comment);
            },
          ),
        ),
        _buildInputField(onSend),
      ],
    );
  }

  // Input field chung
  Widget _buildInputField(VoidCallback onSend) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: inputBackgroundColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Thêm bình luận...',
                hintStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white, size: 20),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
