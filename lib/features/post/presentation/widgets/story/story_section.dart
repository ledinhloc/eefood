import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/post/data/models/user_story_model.dart';
import 'package:eefood/features/post/presentation/provider/story_list_cubit.dart';
import 'package:eefood/features/post/presentation/provider/story_reaction_cubit.dart';
import 'package:eefood/features/post/presentation/provider/story_viewer_cubit.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_page.dart/story_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'crud_story/create_story_card.dart';
import 'story_card.dart';

class StorySection extends StatefulWidget {
  final VoidCallback onCreateStory;
  final Future<void> Function() onRefresh;
  final List<UserStoryModel> userStories;
  final int currentUserId;
  final bool isCreating;

  const StorySection({
    super.key,
    required this.onCreateStory,
    required this.onRefresh,
    required this.userStories,
    required this.currentUserId,
    required this.isCreating,
  });

  @override
  State<StorySection> createState() => _StorySectionState();
}

class _StorySectionState extends State<StorySection> {
  late ScrollController _scrollController;
  bool _isRefreshing = false;
  double _dragDistance = 0;
  static const double _refreshThreshold = 100.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    await widget.onRefresh();

    if (mounted) {
      setState(() {
        _isRefreshing = false;
        _dragDistance = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              // Chỉ xử lý khi scroll đến đầu và đang kéo về bên trái
              if (notification is ScrollUpdateNotification) {
                if (_scrollController.position.pixels <= 0) {
                  setState(() {
                    _dragDistance = -_scrollController.position.pixels;
                  });
                }
              } else if (notification is ScrollEndNotification) {
                if (_dragDistance >= _refreshThreshold) {
                  _handleRefresh();
                } else {
                  setState(() {
                    _dragDistance = 0;
                  });
                }
              }
              return false;
            },
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: widget.userStories.length + 1,
                  itemBuilder: (context, index) {
                    // Ô tạo story
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CreateStoryCard(onTap: widget.onCreateStory),
                      );
                    }

                    final userStory = widget.userStories[index - 1];
                    final stories = userStory.stories;

                    if (stories.isEmpty) {
                      return const SizedBox();
                    }

                    // story đầu tiên sẽ lấy làm thumbnail card
                    final previewStory = stories.first;

                    bool hasUnViewed = userStory.stories.any(
                      (s) => s.isViewed == false,
                    );

                    final isCurrentUserStory =
                        userStory.userId == widget.currentUserId;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MultiBlocProvider(
                                providers: [
                                  BlocProvider.value(
                                    value: context.read<StoryCubit>(),
                                  ),
                                  BlocProvider(
                                    create: (_) => getIt<StoryViewerCubit>(),
                                  ),
                                  BlocProvider.value(
                                    value: getIt<StoryReactionCubit>(),
                                  ),
                                ],
                                child: StoryViewerPage(
                                  allUsers: widget.userStories,
                                  userIndex: index - 1,
                                  currentUserId: widget.currentUserId,
                                ),
                              ),
                            ),
                          );
                        },
                        child: StoryCard(
                          userName: isCurrentUserStory
                              ? "Tin của bạn"
                              : userStory.username ?? "Người dùng",
                          imageUrl: previewStory.contentUrl ?? "",
                          avatarUrl: userStory.avatarUrl ?? "",
                          hasStory: hasUnViewed,
                          isCreating: widget.isCreating && isCurrentUserStory,
                        ),
                      ),
                    );
                  },
                ),

                // Refresh indicator
                if (_dragDistance > 0 || _isRefreshing)
                  Positioned(
                    left: _dragDistance.clamp(0, _refreshThreshold),
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: _isRefreshing
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                Icons.refresh,
                                color: _dragDistance >= _refreshThreshold
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          child: Divider(height: 1, thickness: 1, color: Colors.black12),
        ),
      ],
    );
  }
}
