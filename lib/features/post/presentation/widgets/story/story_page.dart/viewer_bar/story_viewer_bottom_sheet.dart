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
    return DraggableScrollableSheet(
      initialChildSize: 0.98,
      minChildSize: 0.5,
      maxChildSize: 0.98,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
      },
    );
  }

  Widget _buildHandle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
    final bool isVideo = widget.story.type != 'image';
    final String? url = widget.story.contentUrl;

    return Container(
      height: 120,
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
            arguments: {'url': url, 'isVideo': isVideo},
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: url == null
              ? const Icon(Icons.image_outlined, size: 60, color: Colors.grey)
              : !isVideo
              ? CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error_outline, size: 40),
                )
              : Stack(
                  children: [
                    // Thumbnail video
                    CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) =>
                          Container(color: Colors.black12),
                      errorWidget: (context, url, error) =>
                          Container(color: Colors.black12),
                    ),

                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black26,
                            Colors.black45,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),

                    // Icon Play lớn, có shadow
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
