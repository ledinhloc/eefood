import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../provider/block_user_cubit.dart';
import '../../provider/block_user_state.dart';
import 'blocked_user_tile.dart';

class BlockedListTab extends StatelessWidget {
  const BlockedListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlockUserCubit, BlockUserState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
          );
        }

        if (state.users.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0x14EF5350),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_user_outlined,
                      color: Color(0xFFEF7774),
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa chặn ai',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Danh sách người dùng bị chặn sẽ xuất hiện tại đây.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, height: 1.4),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          itemCount: state.users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return BlockedUserTile(user: state.users[index]);
          },
        );
      },
    );
  }
}