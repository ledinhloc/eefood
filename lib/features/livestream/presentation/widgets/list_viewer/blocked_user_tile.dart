import 'package:eefood/app_routes.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/profile/domain/usecases/profile_usecase.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/model/block_user_response.dart';
import '../../provider/block_user_cubit.dart';

class BlockedUserTile extends StatelessWidget {
  final BlockUserResponse user;

  const BlockedUserTile({super.key, required this.user});

  Future<void> _openProfile(BuildContext context) async {
    try {
      final profile = await getIt<GetUserById>().call(user.blockedUserId);
      if (!context.mounted || profile == null) return;

      await Navigator.pushNamed(
        context,
        AppRoutes.personalUser,
        arguments: {'user': profile},
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
    final cubit = context.read<BlockUserCubit>();

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
                    user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                    ? const Icon(Icons.person_rounded, color: Colors.white70)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username ?? 'Người dùng',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Đã bị chặn',
                      style: TextStyle(color: Color(0xFFEF7774), fontSize: 12),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF8B85FF),
                  backgroundColor: const Color(0x146C63FF),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => cubit.unblockUser(user.blockedUserId),
                icon: const Icon(Icons.lock_open_rounded, size: 17),
                label: const Text(
                  'Gỡ chặn',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
