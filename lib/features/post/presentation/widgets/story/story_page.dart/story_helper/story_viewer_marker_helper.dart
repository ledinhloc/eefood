import 'dart:convert';
import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/auth/data/models/UserModel.dart';
import 'package:eefood/features/post/data/models/user_story_model.dart';
import 'package:eefood/features/post/presentation/provider/story_list_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Helper class quản lý việc đánh dấu story đã xem
class StoryViewMarkerHelper {
  final StoryCubit storyCubit;
  final List<UserStoryModel> allUsers;

  StoryViewMarkerHelper({required this.storyCubit, required this.allUsers});

  Future<void> markStoryAsViewed(int userIndex, int storyIndex) async {
    if(storyIndex < 0) return;
    final currentUser = allUsers[userIndex];
    final currentStory = currentUser.stories[storyIndex];

    if (currentStory.isViewed == true) return;

    final updatedStory = currentStory.copyWith(isViewed: true);
    final updatedUser = currentUser.copyWith(
      stories: [
        ...currentUser.stories.sublist(0, storyIndex),
        updatedStory,
        ...currentUser.stories.sublist(storyIndex + 1),
      ],
    );

    final updatedList = [
      ...storyCubit.state.stories.sublist(0, userIndex),
      updatedUser,
      ...storyCubit.state.stories.sublist(userIndex + 1),
    ];

    storyCubit.emit(storyCubit.state.copyWith(stories: updatedList));

    try {
      final user = await _getCurrentUser();
      final storyId = updatedStory.id;

      if (user != null && storyId != null) {
        debugPrint('StoryId $storyId');
        debugPrint('UserId: ${user.id}');
        await storyCubit.markView(storyId: storyId, viewerId: user.id);
      }
    } catch (e) {
      throw Exception('Mark viewed failed $e');
    }
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
}
