import 'package:flutter/material.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../data/models/post_model.dart';
import '../../../../core/widgets/custom_bottom_sheet.dart'; // import file custom

class PostHeader extends StatelessWidget {
  final PostModel post;
  const PostHeader({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const UserAvatar(
        username: 'loc',
        isLocal: false,
        url:
        'https://jbagy.me/wp-content/uploads/2025/03/hinh-anh-cute-avatar-vo-tri-3.jpg',
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
        onPressed: () {
          showCustomBottomSheet(context, [
            BottomSheetOption(
              icon: const Icon(Icons.visibility_off_outlined,
                  color: Colors.grey),
              title: 'Ẩn bài viết này',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã ẩn bài viết này')),
                );
              },
            ),
            BottomSheetOption(
              icon: const Icon(Icons.block_outlined, color: Colors.orange),
              title: 'Ẩn các bài tương tự',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã ẩn các bài tương tự')),
                );
              },
            ),
            BottomSheetOption(
              icon: const Icon(Icons.flag_outlined, color: Colors.red),
              title: 'Báo cáo bài viết',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Báo cáo bài viết')),
                );
              },
            ),
            BottomSheetOption(
              icon: const Icon(Icons.link, color: Colors.blue),
              title: 'Sao chép liên kết món ăn',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã sao chép liên kết món ăn')),
                );
              },
            ),
            BottomSheetOption(
              icon: const Icon(Icons.share_outlined, color: Colors.green),
              title: 'Chia sẻ bài viết',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã chia sẻ bài viết')),
                );
              },
            ),
          ]);
        },
      ),
    );
  }
}
