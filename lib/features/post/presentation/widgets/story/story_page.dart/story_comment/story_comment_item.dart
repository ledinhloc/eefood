import 'package:eefood/core/utils/convert_time.dart';
import 'package:eefood/features/post/data/models/story_comment_model.dart';
import 'package:flutter/material.dart';

class CommentStoryItem extends StatelessWidget {
  final StoryCommentModel comment;
  final int? currentUserId;
  final VoidCallback? onReply;
  final VoidCallback? onUpdate;
  final VoidCallback? onDelete;
  final VoidCallback? onLoadReplies;
  final int replyCount;
  final bool isExpanded;

  const CommentStoryItem({
    super.key,
    required this.comment,
    this.currentUserId,
    this.onReply,
    this.onUpdate,
    this.onDelete,
    this.onLoadReplies,
    this.replyCount = 0,
    this.isExpanded = false
  });

  bool get isOwnComment => comment.userId == currentUserId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: isOwnComment ? () => _showCommentOptions(context) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: isOwnComment
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!isOwnComment) ...[
              CircleAvatar(
                radius: 18,
                backgroundImage: comment.avatarUrl != null
                    ? NetworkImage(comment.avatarUrl!)
                    : null,
                child: comment.avatarUrl == null
                    ? const Icon(Icons.person, size: 18)
                    : null,
              ),
              const SizedBox(width: 12),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isOwnComment
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isOwnComment
                          ? Colors.blue.shade100
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: isOwnComment
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (!isOwnComment)
                          Text(
                            comment.username ?? 'Unknown',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        if (!isOwnComment) const SizedBox(height: 2),
                        Text(
                          comment.message,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          TimeParser.formatCommentTime(comment.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (!isOwnComment) ...[
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: onReply,
                            child: Text(
                              'Trả lời',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        if (replyCount > 0 && onLoadReplies != null) ...[
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: onLoadReplies,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  size: 14,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isExpanded
                                      ? 'Ẩn $replyCount phản hồi'
                                      : 'Xem $replyCount phản hồi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isOwnComment) ...[
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 18,
                backgroundImage: comment.avatarUrl != null
                    ? NetworkImage(comment.avatarUrl!)
                    : null,
                child: comment.avatarUrl == null
                    ? const Icon(Icons.person, size: 18)
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCommentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Cập nhật'),
                onTap: () {
                  Navigator.pop(context);
                  onUpdate?.call();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Xóa'),
                onTap: () {
                  Navigator.pop(context);
                  onDelete?.call();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

}
