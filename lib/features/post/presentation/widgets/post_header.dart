import 'package:flutter/material.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../data/models/post_model.dart';

class PostHeader extends StatelessWidget {
  final PostModel post;
  const PostHeader({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const UserAvatar(
        username: 'loc',
        isLocal: false,
        url: 'https://jbagy.me/wp-content/uploads/2025/03/hinh-anh-cute-avatar-vo-tri-3.jpg',
      ),
      title: const Text(
        'Emily Jane',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(
        '3h ago',
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz, color: Colors.grey),
        onPressed: () {},
      ),
    );
  }
}
