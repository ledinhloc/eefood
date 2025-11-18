import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/auth/data/models/UserModel.dart';
import 'package:eefood/features/post/data/models/user_story_model.dart';
import 'package:eefood/features/post/domain/repositories/story_repository.dart';
import 'package:eefood/features/post/presentation/provider/story_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoryViewerPage extends StatefulWidget {
  final List<UserStoryModel> allUsers;
  final int userIndex;
  final int initialStoryIndex;

  const StoryViewerPage({
    super.key,
    required this.allUsers,
    required this.userIndex,
    this.initialStoryIndex = 0,
  });

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage> {
  late int _userIndex;
  late int _storyIndex;

  Timer? _timer;
  double _progress = 0.0;
  late PageController _pageController;

  final StoryRepository storyRepository = getIt<StoryRepository>();

  @override
  void initState() {
    super.initState();

    _userIndex = widget.userIndex;
    _storyIndex = widget.initialStoryIndex;

    _pageController = PageController(initialPage: _storyIndex);
    _markViewed();
    _startProgress();
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
    } catch (e) {
      debugPrint('Error marking view: $e');
    }
  }

  Future<UserModel?> _getCurrentUser() async {
    try {
      final prefs = getIt<SharedPreferences>();
      final userString = prefs.getString(AppKeys.user);
      if (userString != null) {
        final userMap = jsonDecode(userString);
        return UserModel.fromJson(userMap);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  UserStoryModel get currentUser => widget.allUsers[_userIndex];

  void _startProgress() {
    _timer?.cancel();
    setState(() => _progress = 0.0);

    final story = currentUser.stories[_storyIndex];
    final duration = story.type == "video" ? 10 : 8; // GIẢ LẬP

    _timer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (_progress >= 1) {
        timer.cancel();
        _nextStory();
      } else {
        setState(() => _progress += 0.01 / (duration / 0.08));
      }
    });
  }

  void _nextStory() {
    _markViewed();
    if (_storyIndex < currentUser.stories.length - 1) {
      setState(() {
        _storyIndex++;
        _pageController.animateToPage(
          _storyIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
      _startProgress();
    } else {
      _nextUser();
    }
  }

  void _previousStory() {
    if (_storyIndex > 0) {
      setState(() {
        _storyIndex--;
        _pageController.animateToPage(
          _storyIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
      _startProgress();
    } else {
      _previousUser();
    }
  }

  void _nextUser() {
    if (_userIndex < widget.allUsers.length - 1) {
      setState(() {
        _userIndex++;
        _storyIndex = 0;
        _pageController = PageController(initialPage: 0);
      });
      _markViewed();
      _startProgress();
    } else {
      Navigator.pop(context);
    }
  }

  void _previousUser() {
    if (_userIndex > 0) {
      setState(() {
        _userIndex--;
        _storyIndex = widget.allUsers[_userIndex].stories.length - 1;
        _pageController = PageController(initialPage: _storyIndex);
      });
      _markViewed();
      _startProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (d) {
          final width = MediaQuery.of(context).size.width;
          if (d.globalPosition.dx < width * 0.3) {
            _previousStory();
          } else {
            _nextStory();
          }
        },

        // Vuốt ngang để đổi user
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) {
              _nextUser(); // Vuốt sang trái
            } else {
              _previousUser(); // Vuốt sang phải
            }
          }
        },

        child: Stack(
          children: [
            _buildStoryContent(user),

            SafeArea(
              child: Column(
                children: [
                  _buildProgressBars(user.stories.length),
                  _buildTopBar(user),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryContent(UserStoryModel user) {
    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: user.stories.length,
      itemBuilder: (_, i) {
        final s = user.stories[i];
        return s.type == "video"
            ? const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 110,
                ),
              )
            : CachedNetworkImage(
                imageUrl: s.contentUrl ?? "",
                fit: BoxFit.cover,
              );
      },
    );
  }

  Widget _buildTopBar(UserStoryModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.avatarUrl ?? ""),
            radius: 18,
          ),
          const SizedBox(width: 10),
          Text(
            user.username ?? "",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBars(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        children: List.generate(count, (i) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 4,
              decoration: BoxDecoration(
                color: i < _storyIndex
                    ? Colors.white
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
              child: i == _storyIndex
                  ? FractionallySizedBox(
                      widthFactor: _progress,
                      alignment: Alignment.centerLeft,
                      child: Container(color: Colors.white),
                    )
                  : null,
            ),
          );
        }),
      ),
    );
  }
}
