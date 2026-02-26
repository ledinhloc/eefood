// presentation/widgets/viewer_list_bottom_sheet.dart
import 'package:eefood/core/widgets/custom_bottom_sheet.dart';
import 'package:eefood/features/livestream/presentation/provider/block_user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../provider/live_viewer_cubit.dart';
import '../provider/live_viewer_state.dart';

class ViewerListBottomSheet extends StatelessWidget {
  const ViewerListBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: BlocBuilder<LiveViewerCubit, LiveViewerState>(
        builder: (context, state) {
          return Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Người đang xem (${state.viewers.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white24, height: 1),

              // Viewer list
              Expanded(
                child: state.loading
                    ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
                    : state.viewers.isEmpty
                    ? const Center(
                  child: Text(
                    'Chưa có người xem',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
                    : RefreshIndicator(
                  onRefresh: () => context.read<LiveViewerCubit>().loadViewers(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: state.viewers.length,
                    itemBuilder: (context, index) {
                      final viewer = state.viewers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blue,
                          backgroundImage: viewer.avatarUrl != null
                              ? CachedNetworkImageProvider(viewer.avatarUrl!)
                              : null,
                          child: viewer.avatarUrl == null
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        title: Text(
                          viewer.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          _formatJoinedTime(viewer.joinedAt),
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                        trailing: IconButton(
                            onPressed: () {
                              final  blockUserCubit = context.read<BlockUserCubit>();
                              showCustomBottomSheet(context,
                                [
                                  BottomSheetOption(
                                      icon: const Icon(Icons.block, color: Colors.red,),
                                      title: "Chặn người này",
                                      onTap: () {
                                        blockUserCubit.blockUser(viewer.userId);
                                      },
                                  )
                                ]);
                            },
                            icon: const Icon(Icons.more_vert, color: Colors.white,)),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatJoinedTime(DateTime joinedAt) {
    final now = DateTime.now();
    final difference = now.difference(joinedAt);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }
}