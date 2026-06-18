import 'package:eefood/app_routes.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/livestream/data/model/viewer_model.dart';
import 'package:eefood/features/profile/domain/usecases/profile_usecase.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../provider/block_user_cubit.dart';

class ViewerTile extends StatelessWidget {
  final ViewerModel viewer;

  const ViewerTile({Key? key, required this.viewer}) : super(key: key);

  Future<void> _openProfile(BuildContext context) async {
    try {
      final user = await getIt<GetUserById>().call(viewer.userId);
      if (!context.mounted || user == null) return;

      await Navigator.pushNamed(
        context,
        AppRoutes.personalUser,
        arguments: {'user': user},
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể mở trang cá nhân: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final blockCubit = context.read<BlockUserCubit>();

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: viewer.avatarUrl != null
            ? CachedNetworkImageProvider(viewer.avatarUrl!)
            : null,
        child: viewer.avatarUrl == null ? const Icon(Icons.person) : null,
      ),

      title: GestureDetector(
        onTap: () => _openProfile(context),
        child: Text(
          viewer.username,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
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
