import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../provider/block_user_cubit.dart';

class ViewerTile extends StatelessWidget {

  final dynamic viewer;

  const ViewerTile({
    Key? key,
    required this.viewer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final blockCubit = context.read<BlockUserCubit>();

    return ListTile(

      leading: CircleAvatar(
        backgroundImage: viewer.avatarUrl != null
            ? CachedNetworkImageProvider(viewer.avatarUrl!)
            : null,
        child: viewer.avatarUrl == null
            ? const Icon(Icons.person)
            : null,
      ),

      title: Text(
        viewer.username,
        style: const TextStyle(color: Colors.white),
      ),

      trailing: IconButton(
        icon: const Icon(Icons.block, color: Colors.red),
        onPressed: () {
          blockCubit.blockUser(viewer.userId);
        },
      ),
    );
  }
}