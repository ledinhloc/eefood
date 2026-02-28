import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../provider/block_user_cubit.dart';
import '../provider/block_user_state.dart';
import 'blocked_user_tile.dart';

class BlockedListTab extends StatelessWidget {
  const BlockedListTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<BlockUserCubit, BlockUserState>(
      builder: (context, state) {

        if (state.loading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFF6B35),
            ),
          );
        }

        if (state.users.isEmpty) {
          return const Center(
            child: Text(
              "Chưa chặn ai",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.builder(
          itemCount: state.users.length,
          itemBuilder: (context, index) {

            final user = state.users[index];

            return BlockedUserTile(user: user);
          },
        );
      },
    );
  }
}