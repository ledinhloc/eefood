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

  const ViewerTile({super.key, required this.viewer});

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

    return Material(
      color: const Color(0xFF191D27),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _openProfile(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: const Color(0xFF2A3040),
                backgroundImage:
                    viewer.avatarUrl != null && viewer.avatarUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(viewer.avatarUrl!)
                    : null,
                child: viewer.avatarUrl == null || viewer.avatarUrl!.isEmpty
                    ? const Icon(Icons.person_rounded, color: Colors.white70)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewer.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Row(
                      children: [
                        Icon(Icons.circle, color: Color(0xFF4CD964), size: 8),
                        SizedBox(width: 5),
                        Text(
                          'Đang xem',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Chặn người xem',
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0x1AEF5350),
                ),
                icon: const Icon(
                  Icons.block_rounded,
                  color: Color(0xFFEF7774),
                  size: 21,
                ),
                onPressed: () => blockCubit.blockUser(viewer.userId),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
