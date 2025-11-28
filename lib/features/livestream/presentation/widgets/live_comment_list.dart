import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/live_comment_response.dart';
import '../provider/live_comment_cubit.dart';
import 'live_comment_item.dart';

class LiveCommentList extends StatelessWidget {
  final TextEditingController controller;
  final ScrollController scrollController;

  const LiveCommentList({
    Key? key,
    required this.controller,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveCommentCubit, LiveCommentState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: state.comments.length,
                itemBuilder: (context, index) {
                  final comment = state.comments[index];
                  return Container(
                    // margin: const EdgeInsets.only(bottom: 8),
                    // padding: const EdgeInsets.symmetric(
                    //     horizontal: 12, vertical: 8),
                    // decoration: BoxDecoration(
                    //   color: Colors.black54,
                    //   borderRadius: BorderRadius.circular(20),
                    // ),
                    child: LiveCommentItem(comment: comment),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        hintText: 'Thêm bình luận...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none),
                    onSubmitted: (_) => _sendComment(context),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () => _sendComment(context),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _sendComment(BuildContext context) {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    context.read<LiveCommentCubit>().addComment(text);
    controller.clear();

    // Scroll xuống cuối
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
