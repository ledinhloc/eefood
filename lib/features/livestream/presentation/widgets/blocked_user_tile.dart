import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/model/block_user_response.dart';
import '../provider/block_user_cubit.dart';

class BlockedUserTile extends StatelessWidget {
  final BlockUserResponse user;

  const BlockedUserTile({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BlockUserCubit>();

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.avatarUrl != null
            ? CachedNetworkImageProvider(user.avatarUrl!)
            : null,
      ),

      title: Text(
        user.username ?? "Unknown",
        style: const TextStyle(color: Colors.white),
      ),

      subtitle: const Text("Đã bị chặn", style: TextStyle(color: Colors.red)),

      trailing: TextButton(
        onPressed: () {
          cubit.unblockUser(user.blockedUserId);
        },

        child: const Text(
          "Gỡ chặn",
          style: TextStyle(
            color: Color(0xFFFF6B35),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
