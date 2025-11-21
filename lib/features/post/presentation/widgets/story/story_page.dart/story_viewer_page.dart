import 'dart:async';
import 'dart:convert';

import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/custom_bottom_sheet.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/auth/data/models/UserModel.dart';
import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:eefood/features/post/data/models/user_story_model.dart';
import 'package:eefood/features/post/domain/repositories/story_repository.dart';
import 'package:eefood/features/post/presentation/provider/story_list_cubit.dart';
import 'package:eefood/features/post/presentation/provider/story_reaction_cubit.dart';
import 'package:eefood/features/post/presentation/provider/story_viewer_cubit.dart';
import 'package:eefood/features/post/presentation/widgets/post/reaction_popup.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_page.dart/story_action_bar.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_page.dart/story_content.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_page.dart/story_gesture_layer.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_page.dart/story_progress_bars.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_page.dart/story_top_bar.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_page.dart/viewer_bar/story_viewer_bar.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_page.dart/viewer_bar/story_viewer_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoryViewerPage extends StatefulWidget {
  final List<UserStoryModel> allUsers;
  final int userIndex;
  final int initialStoryIndex;
  final bool? isCurrentUserStory;

  const StoryViewerPage({
    super.key,
    required this.allUsers,
    required this.userIndex,
    this.initialStoryIndex = 0,
    this.isCurrentUserStory,
  });

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage> {
  late int _userIndex;
  late int _storyIndex;
  bool _isPaused = false;

  Timer? _timer;
  double _progress = 0.0;
  int _tick = 0;
  int _totalTicks = 0;
  late PageController _pageController;

  final StoryRepository storyRepository = getIt<StoryRepository>();

  late StoryViewerCubit _storyViewerCubit;
  Timer? _loadViewerDebounce;
  OverlayEntry? _reactionPopup;
  ReactionType _currentReaction = ReactionType.LOVE;

  @override
  void initState() {
    super.initState();
    _userIndex = widget.userIndex;
    _storyIndex = widget.initialStoryIndex;

    _pageController = PageController(initialPage: _storyIndex);

    _storyViewerCubit = context.read<StoryViewerCubit>();

    _markViewed();
    _startProgress();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isCurrentUserStory == true) {
        _loadViewersForCurrentStory();
      }
    });
  }

  UserStoryModel get currentUser => widget.allUsers[_userIndex];

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _hidePopup() {
    _reactionPopup?.remove();
    _reactionPopup = null;
  }

  void _showReactionPopup(
    Offset pos,
    int storyId,
    Function(ReactionType) updateReaction,
  ) {
    _hidePopup();

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    _reactionPopup = OverlayEntry(
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _hidePopup();
          _resume();
        },
        child: Stack(
          children: [
            Positioned(
              left: pos.dx - 10,
              top: pos.dy - 80,
              child: Material(
                color: Colors.transparent,
                child: ReactionPopup(
                  onSelect: (reaction) {
                    updateReaction(reaction);
                    context.read<StoryReactionCubit>().reactToStory(
                      storyId,
                      reaction,
                    );
                    _hidePopup();
                    _resume();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(_reactionPopup!);
  }

  void _onStoryChanged() {
    _markViewed();

    if (widget.isCurrentUserStory == true) {
      _loadViewersForCurrentStory();
    }

    _startProgress();
  }

  void _loadViewersForCurrentStory() {
    _pause();

    _loadViewerDebounce?.cancel();
    _loadViewerDebounce = Timer(const Duration(milliseconds: 300), () async {
      final storyId = currentUser.stories[_storyIndex].id;
      if (storyId != null) {
        // Reset state riêng cho story hiện tại
        _storyViewerCubit.resetForStory(storyId);

        // Load viewers của story hiện tại
        await _storyViewerCubit.loadViewer(storyId: storyId);

        // Resume progress
        if (mounted) _resume();
      }
    });
  }

  void _pause() {
    if (_isPaused) return;
    _isPaused = true;
    _timer?.cancel();
  }

  void _resume() {
    if (!_isPaused) return;
    _isPaused = false;

    if (_tick >= _totalTicks) return;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (_isPaused) return;

      _tick++;
      if (_tick >= _totalTicks) {
        _progress = 1.0;
        t.cancel();
        if (!mounted) return;
        setState(() {});
        _nextStory();
        return;
      }

      if (!mounted) return;
      setState(() {
        _progress = _tick / _totalTicks;
      });
    });
  }

  void _markViewed() async {
    final currentStory = currentUser.stories[_storyIndex];
    if (currentStory.isViewed == true) return;

    final updatedStory = currentStory.copyWith(isViewed: true);
    final updatedUser = currentUser.copyWith(
      stories: [
        ...currentUser.stories.sublist(0, _storyIndex),
        updatedStory,
        ...currentUser.stories.sublist(_storyIndex + 1),
      ],
    );

    final cubit = context.read<StoryCubit>();
    final updatedList = [
      ...cubit.state.stories.sublist(0, _userIndex),
      updatedUser,
      ...cubit.state.stories.sublist(_userIndex + 1),
    ];

    cubit.emit(cubit.state.copyWith(stories: updatedList));

    try {
      final currentUserData = await _getCurrentUser();
      if (currentUserData != null && updatedStory.id != null) {
        await cubit.repository.markViewStory(
          updatedStory.id!,
          currentUserData.id,
        );
      }
    } catch (_) {}
  }

  Future<UserModel?> _getCurrentUser() async {
    try {
      final prefs = getIt<SharedPreferences>();
      final str = prefs.getString(AppKeys.user);
      return str != null ? UserModel.fromJson(jsonDecode(str)) : null;
    } catch (_) {
      return null;
    }
  }

  void _startProgress({Duration? videoDuration}) {
    if (videoDuration == null || videoDuration == Duration.zero) return;

    _timer?.cancel();
    _isPaused = false;
    _tick = 0;

    final duration = videoDuration.inSeconds == 0
        ? const Duration(seconds: 8)
        : videoDuration;

    _totalTicks = duration.inMilliseconds ~/ 50;

    _timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (_isPaused) return;

      _tick++;

      if (_tick >= _totalTicks) {
        _progress = 1.0;
        t.cancel();
        if (!mounted) return;
        setState(() {});
        _nextStory();
        return;
      }

      if (!mounted) return;
      setState(() {
        _progress = _tick / _totalTicks;
      });
    });
  }

  void _nextStory() {
    _pause();
    _markViewed();
    if (_storyIndex < currentUser.stories.length - 1) {
      setState(() {
        _storyIndex++;
        _resetProgress();
        _pageController.animateToPage(
          _storyIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });

      _onStoryChanged();
    } else {
      _nextUser();
    }
  }

  void _previousStory() {
    if (_storyIndex > 0) {
      setState(() {
        _storyIndex--;
        _resetProgress();
        _pageController.animateToPage(
          _storyIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });

      _onStoryChanged();
    } else {
      _previousUser();
    }
  }

  void _nextUser() {
    if (_userIndex < widget.allUsers.length - 1) {
      setState(() {
        _userIndex++;
        _storyIndex = 0;
        _pageController.dispose();
        _pageController = PageController(initialPage: 0);
      });
      _markViewed();

      _onStoryChanged();
    } else {
      Navigator.pop(context);
    }
  }

  void _previousUser() {
    if (_userIndex > 0) {
      setState(() {
        _userIndex--;
        _storyIndex = widget.allUsers[_userIndex].stories.length - 1;
        _pageController.dispose();
        _pageController = PageController(initialPage: _storyIndex);
      });
      _markViewed();

      _onStoryChanged();
    }
  }

  void _resetProgress() {
    _progress = 0.0;
    _tick = 0;
    _timer?.cancel();
  }

  void _openStoryOptions() async {
    final cubit = context.read<StoryCubit>();
    _pause();
    await showCustomBottomSheet(context, [
      BottomSheetOption(
        icon: const Icon(Icons.delete_outlined, color: Colors.redAccent),
        title: 'Xóa story này',
        onTap: () async {
          final currentStory = currentUser.stories[_storyIndex];
          await cubit.deleteStory(currentStory.id!);
          Navigator.pop(context);
          await showCustomSnackBar(context, "Đã xóa story");
        },
      ),
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
      BottomSheetOption(
        icon: const Icon(Icons.link, color: Colors.blue),
        title: 'Sao chép liên kết story',
        onTap: () async {
          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đã sao chép liên kết')));
        },
      ),
    ]).whenComplete(() {
      _resume();
    });
  }

  void _removeDeletedStory(int id) {
    final currentStories = widget.allUsers[_userIndex].stories;

    final index = currentStories.indexWhere((s) => s.id == id);
    if (index == -1) return;

    setState(() {
      currentStories.removeAt(index);

      if (_storyIndex >= currentStories.length) {
        if (_userIndex < widget.allUsers.length - 1) {
          _nextUser();
        } else {
          Navigator.pop(context);
        }
      }
    });
  }

  void _openListViewer() {
    final storyId = currentUser.stories[_storyIndex].id;

    if (storyId != null) {
      _pause();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        builder: (_) {
          return BlocProvider.value(
            value: _storyViewerCubit,
            child: StoryViewerListSheet(
              cubit: _storyViewerCubit,
              storyId: storyId,
            ),
          );
        },
      ).whenComplete(() {
        _resume();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = currentUser;
    final storyId = user.stories[_storyIndex].id;
    final storyReactionCubit = context.read<StoryReactionCubit>();

    return BlocListener<StoryCubit, StoryState>(
      listener: (context, state) {
        if (state.deletedStoryId != null) {
          _removeDeletedStory(state.deletedStoryId!);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: StoryGestureLayer(
          onTapLeft: _previousStory,
          onTapRight: _nextStory,
          onSwipeLeft: _nextUser,
          onSwipeRight: _previousUser,
          onLongPressStart: _pause,
          onLongPressEnd: _resume,
          child: Stack(
            children: [
              StoryContent(
                pageController: _pageController,
                user: user,
                initialStoryIndex: _storyIndex,
                onVideoProgress: (duration) {
                  _startProgress(videoDuration: duration);
                },
              ),

              SafeArea(
                child: Column(
                  children: [
                    StoryProgressBars(
                      count: user.stories.length,
                      index: _storyIndex,
                      progress: _progress,
                    ),
                    StoryTopBar(
                      user: user,
                      story: user.stories[_storyIndex],
                      onMorePressed: _openStoryOptions,
                    ),
                  ],
                ),
              ),
              if (widget.isCurrentUserStory!) ...[
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  // Sử dụng BlocProvider.value
                  //_pause();với cubit đã tạo sẵn
                  child: BlocProvider.value(
                    value: _storyViewerCubit,
                    child: BlocBuilder<StoryViewerCubit, StoryViewerState>(
                      buildWhen: (previous, current) {
                        if (previous.totalElements != current.totalElements)
                          return true;
                        if (previous.totalElements != current.totalElements)
                          return true;

                        if (previous.viewers.length != current.viewers.length)
                          return true;

                        for (int i = 0; i < previous.viewers.length; i++) {
                          if (previous.viewers[i].id != current.viewers[i].id)
                            return true;
                          if (previous.viewers[i].avatarUrl !=
                              current.viewers[i].avatarUrl)
                            return true;
                        }
                        return false;
                      },
                      builder: (context, state) {
                        return StoryViewerBar(
                          total: state.totalElements ?? 0,
                          viewers: state.viewers,
                          onOpenList: _openListViewer,
                        );
                      },
                    ),
                  ),
                ),
              ] else ...[
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: StoryActionBar(
                    storyId: storyId,
                    onSendComment: (text) async {
                      final story = currentUser.stories[_storyIndex];
                      showCustomSnackBar(context, "Đã gửi bình luận");
                    },
                    onReact: (reaction) {
                      if (storyId != null)
                        storyReactionCubit.reactToStory(storyId, reaction);
                    },
                    onPause: _pause,
                    onResume: _resume,
                    onOpenReactionPopup: (pos) {
                      final story = currentUser.stories[_storyIndex];
                      if (story.id != null) {
                        _showReactionPopup(pos, story.id!, (reactions) {
                          storyReactionCubit.reactToStory(story.id!, reactions);
                        });
                      }
                    },
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
