import 'package:flutter/material.dart';
import 'package:eefood/features/livestream/data/model/live_comment_response.dart';
import 'package:eefood/core/di/injection.dart';

import '../../../../app_routes.dart';
import '../../../profile/domain/usecases/profile_usecase.dart';

class LiveCommentItem extends StatelessWidget {
  final LiveCommentResponse comment;

  const LiveCommentItem({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar bên trái
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            backgroundImage:
            comment.avatarUrl != null ? NetworkImage(comment.avatarUrl!) : null,
            child: comment.avatarUrl == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          // Tên và message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên có thể nhấn vào
                GestureDetector(
                  onTap: () async {
                    try {
                      // Lấy thông tin user
                      final userStory = await getIt<GetUserById>().call(comment.userId);
                      if (userStory != null) {
                        await Navigator.pushNamed(
                          context,
                          AppRoutes.personalUser,
                          arguments: {'user': userStory},
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Không thể mở trang cá nhân: $e')),
                      );
                    }
                  },
                  child: Text(
                    comment.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 0),
                // Message
                Text(
                  comment.message,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}