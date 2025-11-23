import 'package:cached_network_image/cached_network_image.dart';
import 'package:eefood/core/utils/reaction_helper.dart';
import 'package:eefood/features/post/presentation/provider/story_reaction_list_cubit.dart';
import 'package:eefood/features/post/presentation/provider/story_viewer_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoryViewerTab extends StatefulWidget {
  final int storyId;
  final StoryViewerCubit viewerCubit;

  const StoryViewerTab({
    super.key,
    required this.storyId,
    required this.viewerCubit,
  });

  @override
  State<StoryViewerTab> createState() => _StoryViewerTabState();
}

class _StoryViewerTabState extends State<StoryViewerTab> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 80) {
      widget.viewerCubit.loadViewer(storyId: widget.storyId, loadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryViewerCubit, StoryViewerState>(
      builder: (context, state) {
        if (state.isLoading && state.viewers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.viewers.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility_off,
                  size: 50,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Chưa có người xem',
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await widget.viewerCubit.loadViewer(
              storyId: widget.storyId,
              loadMore: false,
            );
          },
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: state.viewers.length + (state.isLoading ? 1 : 0),
            itemBuilder: (context, i) {
              if (i == state.viewers.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final viewer = state.viewers[i];

              // Tìm reaction của viewer này
              final reactionState = context
                  .watch<StoryReactionStatsCubit>()
                  .state;
              final reaction = reactionState.reactions
                  .where((r) => r.userId == viewer.id)
                  .firstOrNull;

              return ListTile(
                leading: _buildAvatarWithReaction(
                  avatarUrl: viewer.avatarUrl,
                  reactionType: reaction?.reactionType,
                ),
                title: Text(
                  viewer.username ?? 'Người dùng',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                subtitle: reaction != null
                    ? Text(
                        'Đã bày tỏ cảm xúc',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      )
                    : null,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAvatarWithReaction({String? avatarUrl, dynamic reactionType}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
              ? CachedNetworkImageProvider(avatarUrl)
              : null,
          child: (avatarUrl == null || avatarUrl.isEmpty)
              ? const Icon(Icons.person, color: Colors.grey)
              : null,
        ),
        if (reactionType != null)
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: Text(
                ReactionHelper.emoji(reactionType),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
      ],
    );
  }
}
