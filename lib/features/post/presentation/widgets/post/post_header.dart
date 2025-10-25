import 'package:flutter/material.dart';
import '../../../../../core/widgets/user_avatar.dart';
import '../../../data/models/post_model.dart';
import '../../../../../core/widgets/custom_bottom_sheet.dart';
import '../collection/add_to_collection_sheet.dart'; // import file custom

class PostHeader extends StatelessWidget {
  final PostModel post;
  const PostHeader({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      horizontalTitleGap: 6,
      leading: UserAvatar(
        username: post.username,
        isLocal: false,
        url: post.avatarUrl,
      ),
      title: Text(
        post.username,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
              icon: const Icon(Icons.bookmark_add, color: Colors.blue),
              title: 'Lưu vào bộ sưu tập',
              onTap: () {
                // Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => AddToCollectionSheet(postId: post.id),
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
