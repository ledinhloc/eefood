import 'package:eefood/core/widgets/user_avatar.dart';
import 'package:eefood/features/auth/data/models/UserModel.dart';
import 'package:eefood/features/post/data/models/follow_model.dart';
import 'package:eefood/features/post/presentation/widgets/follow/follow_item_button.dart';
import 'package:flutter/material.dart';

class FollowItem extends StatelessWidget {
  final FollowModel user;
  const FollowItem({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: UserAvatar(
        username: user.username!,
        radius: 24,
        url: user.avatarUrl,
      ),
      title: Text(
        user.username!,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        user.email ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: FollowItemButton(targetUser: user),
    );
  }
}
