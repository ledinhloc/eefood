import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/custom_bottom_sheet.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/post/data/models/user_story_model.dart';
import 'package:eefood/features/post/domain/repositories/story_repository.dart';
import 'package:eefood/features/post/presentation/provider/story_collection_cubit.dart';
import 'package:eefood/features/post/presentation/provider/story_comment_cubit.dart';
import 'package:eefood/features/post/presentation/provider/story_list_cubit.dart';
import 'package:eefood/features/post/presentation/provider/story_reaction_cubit.dart';
import 'package:eefood/features/post/presentation/provider/story_reaction_list_cubit.dart';
import 'package:eefood/features/post/presentation/provider/story_viewer_cubit.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_collection/story_collection_page.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_page.dart/story_action_bar.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_page.dart/story_content.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_page.dart/story_gesture_layer.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_page.dart/story_helper/story_navigation_helper.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_page.dart/story_helper/story_progress_helper.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_page.dart/story_helper/story_reaction_helper.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_page.dart/story_helper/story_viewer_loader_helper.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_page.dart/story_helper/story_viewer_marker_helper.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_page.dart/story_progress_bars.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_page.dart/story_top_bar.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_page.dart/viewer_bar/story_viewer_bar.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_page.dart/viewer_bar/story_viewer_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoryViewerPage extends StatefulWidget {
  final List<UserStoryModel> allUsers;
  final int userIndex;
  final int initialStoryIndex;
  final int? currentUserId;
  final bool? isCollection;

  const StoryViewerPage({
    super.key,
    required this.allUsers,
    required this.userIndex,
    this.initialStoryIndex = 0,
    this.currentUserId,
    this.isCollection,
  });

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage> {
  // Helpers
  late StoryProgressHelper _progressHelper;
  late StoryNavigationHelper _navigationHelper;
  late StoryReactionHelper _reactionHelper;
  late StoryViewerLoaderHelper _viewerLoaderHelper;
  late StoryViewMarkerHelper _viewMarkerHelper;

  // Cubits
  late StoryViewerCubit _storyViewerCubit;
  late StoryReactionStatsCubit _reactionStatsCubit;
  late StoryCommentCubit _commentCubit;
  late StoryReactionCubit _reactionCubit;
  final StoryRepository storyRepository = getIt<StoryRepository>();

  Duration _videoDuration = Duration();

  @override
  void initState() {
    super.initState();

    _storyViewerCubit = context.read<StoryViewerCubit>();
    _reactionStatsCubit = context.read<StoryReactionStatsCubit>();
    _commentCubit = getIt<StoryCommentCubit>();
    _reactionCubit = context.read<StoryReactionCubit>();

    // Initialize helpers
    _progressHelper = StoryProgressHelper(
      onProgressUpdate: () {
        if (mounted) setState(() {});
      },
      onComplete: () => _navigationHelper.nextStory(),
    );

    _navigationHelper = StoryNavigationHelper(
      allUsers: widget.allUsers,
      initialUserIndex: widget.userIndex,
      initialStoryIndex: widget.initialStoryIndex,
      onNavigationChanged: _onStoryChanged,
      onComplete: () => Navigator.pop(context),
      onResetProgress: () {
        final currentStory =
            _navigationHelper.currentUser.stories[_navigationHelper.storyIndex];
        if (currentStory.type == 'video') {
          _progressHelper.start(videoDuration: _videoDuration);
        } else {
          _progressHelper.start(videoDuration: const Duration(seconds: 8));
        }
      },
    );

    _reactionHelper = StoryReactionHelper(
      onPause: _progressHelper.pause,
      onResume: _progressHelper.resume,
    );

    _viewerLoaderHelper = StoryViewerLoaderHelper(
      cubit: _storyViewerCubit,
      onPause: _progressHelper.pause,
      onResume: _progressHelper.resume,
    );

    _viewMarkerHelper = StoryViewMarkerHelper(
      storyCubit: context.read<StoryCubit>(),
      allUsers: widget.allUsers,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isCollection!) {
        _viewMarkerHelper.markStoryAsViewedNoneState(
          widget.userIndex,
          widget.initialStoryIndex,
        );
      } else {
        _viewMarkerHelper.markStoryAsViewed(
          widget.userIndex,
          widget.initialStoryIndex,
        );
      }
      if (_isCurrentUserStory()) {
        _loadViewersForCurrentStory();
      } else {
        _loadStatsForCurrentStory();
      }
    });
  }

  @override
  void dispose() {
    _progressHelper.dispose();
    _navigationHelper.dispose();
    _reactionHelper.dispose();
    _viewerLoaderHelper.dispose();
    super.dispose();
  }

  bool _isCurrentUserStory() {
    if (widget.currentUserId == null) return false;
    final currentUser = _navigationHelper.currentUser;
    return currentUser.userId == widget.currentUserId;
  }

  void _onStoryChanged() {
    if (widget.isCollection!) {
      _viewMarkerHelper.markStoryAsViewedNoneState(
        widget.userIndex,
        widget.initialStoryIndex,
      );
    } else {
      _viewMarkerHelper.markStoryAsViewed(
        widget.userIndex,
        widget.initialStoryIndex,
      );
    }

    _progressHelper.reset();

    _reactionCubit.reset();

    setState(() {});

    if (_isCurrentUserStory()) {
      _reactionStatsCubit.reset();
      _commentCubit.reset();
      _loadViewersForCurrentStory();
    } else {
      _reactionStatsCubit.reset();
      _commentCubit.reset();
      _loadStatsForCurrentStory();
    }
  }

  void _loadViewersForCurrentStory() async {
    final storyId =
        _navigationHelper.currentUser.stories[_navigationHelper.storyIndex].id;
    if (storyId != null) {
      _viewerLoaderHelper.loadViewersForStory(storyId);
      await _reactionStatsCubit.loadReactions(storyId: storyId);
      print('Loading viewers and reactions for story $storyId');
    }
  }

  void _loadStatsForCurrentStory() async {
    final storyId =
        _navigationHelper.currentUser.stories[_navigationHelper.storyIndex].id;
    if (storyId != null) {
      final storyReactionCubit = context.read<StoryReactionCubit>();
      storyReactionCubit.loadReactionForStory(storyId);

      await _reactionStatsCubit.loadReactions(storyId: storyId);
      await _commentCubit.loadComments(storyId);
      print('Loading stats for story $storyId');
    }
  }

  void _openStoryOptions(int userId) async {
    final cubit = context.read<StoryCubit>();
    _progressHelper.pause();

    await showCustomBottomSheet(context, [
      if (userId == widget.currentUserId) ...[
        BottomSheetOption(
          icon: const Icon(Icons.link, color: Colors.blue),
          title: 'Thêm vào danh mục tin',
          onTap: () async {
            Navigator.pop(context);
            final currentStory = _navigationHelper
                .currentUser
                .stories[_navigationHelper.storyIndex];

            if (currentStory.id != null && widget.currentUserId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) =>
                        getIt<StoryCollectionCubit>()
                          ..loadCollections(widget.currentUserId!),
                    child: StoryCollectionPage(
                      userId: widget.currentUserId!,
                      storyId: currentStory.id!,
                    ),
                  ),
                ),
              );
            }
          },
        ),
        BottomSheetOption(
          icon: const Icon(Icons.delete_outlined, color: Colors.redAccent),
          title: 'Xóa story này',
          onTap: () async {
            final currentStory = _navigationHelper
                .currentUser
                .stories[_navigationHelper.storyIndex];
            await cubit.deleteStory(currentStory.id!);
            Navigator.pop(context);
            await showCustomSnackBar(context, "Đã xóa story");
          },
        ),
      ] else ...[
        BottomSheetOption(
          icon: const Icon(Icons.report_gmailerrorred, color: Colors.yellow),
          title: 'Báo cáo story',
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Đã báo cáo story')));
          },
        ),
      ],
      BottomSheetOption(
        icon: const Icon(Icons.download, color: Colors.greenAccent),
        title: 'Tải xuống',
        onTap: () async {
          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đã sao chép liên kết')));
        },
      ),
    ]).whenComplete(() {
      _progressHelper.resume();
    });
  }

  void _removeDeletedStory(int id) {
    final currentStories = widget.allUsers[_navigationHelper.userIndex].stories;

    final index = currentStories.indexWhere((s) => s.id == id);
    if (index == -1) return;

    setState(() {
      currentStories.removeAt(index);

      if (_navigationHelper.storyIndex >= currentStories.length) {
        if (_navigationHelper.userIndex < widget.allUsers.length - 1) {
          _navigationHelper.nextUser();
        } else {
          Navigator.pop(context);
        }
      }
    });
  }

  void _openListViewer() {
    final storyId =
        _navigationHelper.currentUser.stories[_navigationHelper.storyIndex].id;
    final currentStory =
        _navigationHelper.currentUser.stories[_navigationHelper.storyIndex];

    if (storyId != null) {
      _progressHelper.pause();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: true,
        enableDrag: true,
        useSafeArea: true,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: MultiBlocProvider(
              providers: [
                BlocProvider.value(value: _storyViewerCubit),
                BlocProvider.value(value: _reactionStatsCubit),
                BlocProvider.value(value: _commentCubit),
              ],
              child: StoryViewerListSheet(
                viewerCubit: _storyViewerCubit,
                reactionCubit: _reactionStatsCubit,
                commentCubit: _commentCubit,
                storyId: storyId,
                story: currentStory,
                currentUserId: widget.currentUserId,
              ),
            ),
          );
        },
      ).whenComplete(() {
        _progressHelper.resume();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _navigationHelper.currentUser;
    final storyIndex = _navigationHelper.storyIndex;
    final storyId = user.stories[storyIndex].id;
    final storyReactionCubit = context.read<StoryReactionCubit>();
    final isViewingOwnStory = _isCurrentUserStory();

    return BlocListener<StoryCubit, StoryState>(
      listener: (context, state) {
        if (state.deletedStoryId != null) {
          _removeDeletedStory(state.deletedStoryId!);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: StoryGestureLayer(
          onTapLeft: () {
            _progressHelper.reset();
            _navigationHelper.previousStory();
          },
          onTapRight: () {
            _progressHelper.reset();
            _navigationHelper.nextStory();
          },
          onSwipeLeft: () {
            _progressHelper.reset();
            _navigationHelper.nextUser();
          },
          onSwipeRight: () {
            _progressHelper.reset();
            _navigationHelper.previousUser();
          },
          onLongPressStart: _progressHelper.pause,
          onLongPressEnd: _progressHelper.resume,
          child: Stack(
            children: [
              StoryContent(
                key: ValueKey('user_${_navigationHelper.userIndex}'),
                pageController: _navigationHelper.pageController,
                user: user,
                initialStoryIndex: storyIndex,
                onVideoProgress: (duration) {
                  _videoDuration = duration!;
                  _progressHelper.start(videoDuration: duration);
                },
              ),
              SafeArea(
                child: Column(
                  children: [
                    StoryProgressBars(
                      count: user.stories.length,
                      index: storyIndex,
                      progress: _progressHelper.progress,
                    ),
                    StoryTopBar(
                      user: user,
                      story: user.stories[storyIndex],
                      onMorePressed: () {
                        _openStoryOptions(user.userId);
                      },
                    ),
                  ],
                ),
              ),
              if (isViewingOwnStory) ...[
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: _storyViewerCubit),
                      BlocProvider.value(value: _reactionStatsCubit),
                    ],
                    child: StoryViewerBar(
                      key: ValueKey(
                        "viewer_${_navigationHelper.currentUser.userId}_$storyIndex",
                      ),
                      onOpenList: _openListViewer,
                    ),
                  ),
                ),
              ] else ...[
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 120,
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: _reactionStatsCubit),
                      BlocProvider.value(value: _commentCubit),
                      BlocProvider.value(
                        value: _reactionCubit, // ADD THIS
                      ),
                      BlocProvider.value(value: _reactionStatsCubit),
                    ],
                    child: SafeArea(
                      child: Container(
                        alignment: Alignment.bottomRight,
                        padding: const EdgeInsets.only(bottom: 8, right: 12),
                        child: StoryActionBar(
                          key: ValueKey('action_bar_$storyId'),
                          storyId: storyId,
                          currentUserId: widget.currentUserId,
                          onReact: (reaction) {
                            if (storyId != null) {
                              if (_reactionCubit.state.reaction != null) {
                                _reactionStatsCubit.decrementReaction(
                                  _reactionCubit.state.reaction!.reactionType,
                                );
                              }
                              _reactionStatsCubit.incrementReaction(reaction);

                              _reactionCubit
                                  .reactToStory(storyId, reaction)
                                  .then((_) {
                                    // Reload to ensure consistency
                                    Future.delayed(
                                      const Duration(milliseconds: 500),
                                      () {
                                        if (mounted) {
                                          _reactionStatsCubit.loadReactions(
                                            storyId: storyId,
                                          );
                                        }
                                      },
                                    );
                                  });
                            }
                          },
                          onPause: _progressHelper.pause,
                          onResume: _progressHelper.resume,
                          onOpenReactionPopup: (pos) {
                            final story = user.stories[storyIndex];
                            if (story.id != null) {
                              _reactionHelper.showReactionPopup(context, pos, (
                                reaction,
                              ) {
                                // Handle optimistic update
                                if (_reactionCubit.state.reaction != null) {
                                  _reactionStatsCubit.decrementReaction(
                                    _reactionCubit.state.reaction!.reactionType,
                                  );
                                }
                                _reactionStatsCubit.incrementReaction(reaction);

                                _reactionCubit
                                    .reactToStory(story.id!, reaction)
                                    .then((_) {
                                      // Reload to ensure consistency
                                      Future.delayed(
                                        const Duration(milliseconds: 500),
                                        () {
                                          if (mounted) {
                                            _reactionStatsCubit.loadReactions(
                                              storyId: story.id!,
                                            );
                                          }
                                        },
                                      );
                                    });
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
