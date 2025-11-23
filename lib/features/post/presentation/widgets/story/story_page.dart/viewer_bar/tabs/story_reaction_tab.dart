import 'package:cached_network_image/cached_network_image.dart';
import 'package:eefood/core/utils/reaction_helper.dart';
import 'package:eefood/features/post/presentation/provider/story_reaction_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoryReactionTab extends StatefulWidget {
  final int storyId;
  final StoryReactionStatsCubit reactionCubit;

  const StoryReactionTab({
    super.key,
    required this.storyId,
    required this.reactionCubit,
  });

  @override
  State<StoryReactionTab> createState() => _StoryReactionTabState();
}

class _StoryReactionTabState extends State<StoryReactionTab> {
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
      widget.reactionCubit.loadReactions(
        storyId: widget.storyId,
        loadMore: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryReactionStatsCubit, StoryReactionStatsState>(
      builder: (context, state) {
        if (state.isLoading && state.reactions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.reactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sentiment_neutral,
                  size: 50,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Chưa có cảm xúc',
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await widget.reactionCubit.loadReactions(
              storyId: widget.storyId,
              loadMore: false,
            );
          },
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: state.reactions.length + (state.isLoading ? 1 : 0),
            itemBuilder: (context, i) {
              if (i == state.reactions.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final reaction = state.reactions[i];

              return ListTile(
                leading: _buildAvatarWithReaction(
                  avatarUrl: reaction.avatarUrl,
                  reactionType: reaction.reactionType,
                ),
                title: Text(
                  reaction.username ?? 'Người dùng',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAvatarWithReaction({
    String? avatarUrl,
    required dynamic reactionType,
  }) {
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
