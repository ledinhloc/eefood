import 'package:cached_network_image/cached_network_image.dart';
import 'package:eefood/app_routes.dart';
import 'package:eefood/features/post/data/models/story_model.dart';
import 'package:eefood/features/post/presentation/provider/story_comment_cubit.dart';
import 'package:eefood/features/post/presentation/provider/story_reaction_list_cubit.dart';
import 'package:eefood/features/post/presentation/provider/story_viewer_cubit.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_page.dart/viewer_bar/tabs/story_comment_tab.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_page.dart/viewer_bar/tabs/story_reaction_tab.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_page.dart/viewer_bar/tabs/story_viewer_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoryViewerListSheet extends StatefulWidget {
  final int storyId;
  final StoryViewerCubit viewerCubit;
  final StoryReactionStatsCubit reactionCubit;
  final StoryModel story;
  final StoryCommentCubit commentCubit;
  final int? currentUserId;

  const StoryViewerListSheet({
    super.key,
    required this.viewerCubit,
    required this.reactionCubit,
    required this.storyId,
    required this.commentCubit,
    required this.story,
    this.currentUserId,
  });

  @override
  State<StoryViewerListSheet> createState() => _StoryViewerListSheetState();
}

class _StoryViewerListSheetState extends State<StoryViewerListSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          const SizedBox(height: 16),
          _buildStoryPreview(),
          const SizedBox(height: 20),
          _buildTabBar(),
          Expanded(child: _buildTabBarView()),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          height: 5,
          width: 45,
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  Widget _buildStoryPreview() {
    return Container(
      height: 180,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.mediaView,
            arguments: {
              'url': widget.story.contentUrl,
              'isVideo': widget.story.type == 'image' ? false : true,
            },
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: widget.story.contentUrl != null
              ? CachedNetworkImage(
                  imageUrl: widget.story.contentUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.error_outline,
                    size: 40,
                    color: Colors.grey,
                  ),
                )
              : const Icon(Icons.image_outlined, size: 60, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.black,
        indicatorWeight: 2,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        tabs: [
          BlocBuilder<StoryViewerCubit, StoryViewerState>(
            builder: (context, state) {
              return Tab(text: 'Người xem (${state.totalElements ?? 0})');
            },
          ),
          BlocBuilder<StoryReactionStatsCubit, StoryReactionStatsState>(
            builder: (context, state) {
              return Tab(text: 'Cảm xúc (${state.totalReactions})');
            },
          ),
          BlocBuilder<StoryCommentCubit, StoryCommentState>(
            builder: (context, state) {
              return Tab(text: 'Bình luận (${state.totalElements})');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        StoryViewerTab(
          storyId: widget.storyId,
          viewerCubit: widget.viewerCubit,
        ),
        StoryReactionTab(
          storyId: widget.storyId,
          reactionCubit: widget.reactionCubit,
        ),
        StoryCommentTab(
          storyId: widget.storyId,
          currentUserId: widget.currentUserId,
        ),
      ],
    );
  }
}
