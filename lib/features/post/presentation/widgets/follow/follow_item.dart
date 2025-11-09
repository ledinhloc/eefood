import 'package:eefood/core/widgets/user_avatar.dart';
import 'package:eefood/features/post/data/models/follow_model.dart';
import 'package:eefood/features/post/presentation/widgets/follow/follow_item_button.dart';
import 'package:flutter/material.dart';

class FollowItem extends StatelessWidget {
  final FollowModel user;
  final bool isFollowersList;
  const FollowItem({
    super.key,
    required this.user,
    required this.isFollowersList,
  });

  @override
  Widget build(BuildContext context) {
    String? userName;
    if(user.username!=null) {
      userName = user.username;
    }
    
    return ListTile(
      leading: UserAvatar(
        username: userName!,
        radius: 24,
        url: user.avatarUrl,
      ),
      title: Text(
        userName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        user.email ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: FollowItemButton(
        targetUser: user,
        isFollowersList: isFollowersList,
      ),
    );
  }
}
