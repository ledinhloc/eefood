import 'package:eefood/features/post/data/models/user_story_model.dart';
import 'package:flutter/material.dart';

class StoryNavigationHelper {
  final List<UserStoryModel> allUsers;
  final VoidCallback onNavigationChanged;
  final VoidCallback onComplete;
  final VoidCallback onResetProgress;

  int _userIndex;
  int _storyIndex;
  PageController _pageController;

  StoryNavigationHelper({
    required this.allUsers,
    required int initialUserIndex,
    required int initialStoryIndex,
    required this.onNavigationChanged,
    required this.onComplete,
    required this.onResetProgress,
  }) : _userIndex = initialUserIndex,
       _storyIndex = initialStoryIndex,
       _pageController = PageController(initialPage: initialStoryIndex);

  int get userIndex => _userIndex;
  int get storyIndex => _storyIndex;
  PageController get pageController => _pageController;
  UserStoryModel get currentUser => allUsers[_userIndex];

  void nextStory() {
    if (currentUser.stories.isEmpty) {
      onComplete();
      return;
    }

    if (_storyIndex < currentUser.stories.length - 1) {
      /// Tăng story index
      _storyIndex++;

      _pageController.animateToPage(
        _storyIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      onNavigationChanged();
    } else {
      nextUser();
    }
  }

  void previousStory() {
    if (currentUser.stories.isEmpty) {
      onResetProgress();
      return;
    }

    if (currentUser.stories.length == 1) {
      _storyIndex = 0;
      onResetProgress();
      return;
    }

    if (_storyIndex > 0) {
      _storyIndex--;
      _pageController.animateToPage(
        _storyIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      onNavigationChanged();
    } else {
      previousUser();
    }
  }

  void nextUser() {
    if (_userIndex >= allUsers.length - 1) {
      onComplete();
      return;
    }
    if (_userIndex < allUsers.length - 1) {
      _userIndex++;
      _storyIndex = 0;
      _pageController.dispose();
      _pageController = PageController(initialPage: 0);
      onNavigationChanged();
    } else {
      onComplete();
    }
  }

  void previousUser() {
    if (_userIndex == 0) {
      onResetProgress();
      return;
    }

    final prevUser = allUsers[_userIndex - 1];

    if (prevUser.stories.isEmpty) {
      _userIndex--;
      _storyIndex = 0;
      _pageController.dispose();
      _pageController = PageController(initialPage: 0);
      onNavigationChanged();
      return;
    }

    final newStoryIndex = prevUser.stories.length - 1;

    _userIndex--;
    _storyIndex = newStoryIndex;
    _pageController.dispose();
    _pageController = PageController(initialPage: newStoryIndex);
    onNavigationChanged();
  }

  void updateIndices(int userIndex, int storyIndex) {
    _userIndex = userIndex;
    _storyIndex = storyIndex;
  }

  void dispose() {
    _pageController.dispose();
  }
}
