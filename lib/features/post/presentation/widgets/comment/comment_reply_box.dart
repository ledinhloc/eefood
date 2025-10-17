import 'package:flutter/material.dart';
import 'package:eefood/features/post/data/models/comment_model.dart';

class CommentReplyTag extends StatelessWidget {
  final CommentModel replyingTo;
  final VoidCallback onCancel;

  const CommentReplyTag({
    super.key,
    required this.replyingTo,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Đang trả lời ${replyingTo.username}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: onCancel,
            child: const Icon(Icons.close, size: 16),
          ),
        ],
      ),
    );
  }
}
