import 'dart:io';

import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/file_upload.dart';
import 'package:eefood/core/utils/save_file_media.dart';
import 'package:eefood/features/post/data/models/story_model.dart';
import 'package:eefood/features/post/data/models/user_story_model.dart';
import 'package:eefood/features/post/domain/repositories/story_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoryCubit extends Cubit<StoryState> {
  final StoryRepository repository = getIt<StoryRepository>();
  final FileUploader fileUploader = getIt<FileUploader>();

  StoryCubit() : super(StoryState.initial());

  void _safeEmit(StoryState state) {
    if (!isClosed) {
      emit(state);
    }
  }

  Future<void> createStory(File file, {int? userId, String? type}) async {
    try {
      _safeEmit(state.copyWith(isCreating: true));

      final savePath = await SaveFileMedia.saveFileToGallery(
        file,
        isImage: type == 'image',
      );

      final uploadUrl = await fileUploader.uploadFile(file);

      final story = StoryModel(
        userId: userId ?? 0,
        type: type,
        contentUrl: uploadUrl,
        createdAt: DateTime.now(),
      );

      await repository.createStory(story);

      _safeEmit(
        state.copyWith(
          isCreating: false,
          createdStory: story,
          savePath: savePath,
          uploadUrl: uploadUrl,
        ),
      );
    } catch (e) {
      _safeEmit(state.copyWith(isCreating: false, error: e.toString()));
    }
  }

  Future<void> updateStory(StoryModel story) async {
    try {
      _safeEmit(state.copyWith(isLoading: true));

      final updated = await repository.updateStory(story);

      _safeEmit(
        state.copyWith(
          isLoading: false,
          isSuccess: true,
          updatedStory: updated,
        ),
      );
    } catch (e) {
      _safeEmit(
        state.copyWith(isLoading: false, isSuccess: false, error: e.toString()),
      );
    }
  }

  Future<void> deleteStory(int id) async {
    try {
      _safeEmit(state.copyWith(isLoading: true));

      await repository.deleteStory(id);

      _safeEmit(
        state.copyWith(isLoading: false, isSuccess: true, deletedStoryId: id),
      );
    } catch (e) {
      _safeEmit(
        state.copyWith(isLoading: false, isSuccess: false, error: e.toString()),
      );
    }
  }

  Future<void> loadStories(int viewerId, {bool? isCollection = false}) async {
    try {
      _safeEmit(state.copyWith(isLoading: true));

      // Lấy own story
      UserStoryModel? ownStories;
      try {
        ownStories = await repository.getOwnStory();
        print('Own story loaded: $ownStories');
      } catch (e) {
        print('No own story or error: $e');
        ownStories = null;
      }

      // Lấy feed story
      var feedStories;
      if(isCollection==true) {
        feedStories = null;
      }
      else {
        feedStories = await repository.getFeed(viewerId);
        print('Feed stories count: ${feedStories.length}');
      }
      

      // Gộp: ownStory -> feedStory
      final mergedRaw = [if (ownStories != null) ownStories, ...feedStories];

      // Loại bỏ trùng userId
      final merged = mergedRaw.fold<List<UserStoryModel>>([], (list, item) {
        if (!list.any((e) => e.userId == item.userId)) {
          list.add(item);
        }
        return list;
      });

      _safeEmit(
        state.copyWith(isLoading: false, ownStory: ownStories, stories: merged),
      );
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> markView({required int storyId, required int viewerId}) async {
    try {
      await repository.markViewStory(storyId, viewerId);
    } catch (e) {
      throw new Exception('Failed to mark view $e');
    }
  }
}

enum StoryStatus { initial, uploading, success, failure }

class StoryState {
  final bool isLoading;
  final bool? isSuccess;
  final bool isCreating;

  final String? error;

  // Create
  final StoryModel? createdStory;
  final String? savePath;
  final String? uploadUrl;
  final List<File> uploadingFiles;

  // Update
  final StoryModel? updatedStory;

  // Delete
  final int? deletedStoryId;

  // Story feed
  final List<UserStoryModel> stories;
  final UserStoryModel? ownStory;

  StoryState({
    required this.isLoading,
    required this.stories,
    required this.isCreating,
    required this.uploadingFiles,
    this.isSuccess,
    this.error,
    this.createdStory,
    this.savePath,
    this.uploadUrl,
    this.updatedStory,
    this.deletedStoryId,
    this.ownStory,
  });

  factory StoryState.initial() => StoryState(
    isCreating: false,
    isLoading: false,
    isSuccess: null,
    stories: [],
    ownStory: null,
    createdStory: null,
    updatedStory: null,
    deletedStoryId: null,
    error: null,
    savePath: null,
    uploadUrl: null,
    uploadingFiles: [],
  );

  StoryState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isCreating,
    String? error,
    StoryModel? createdStory,
    String? savePath,
    String? uploadUrl,
    StoryModel? updatedStory,
    int? deletedStoryId,
    List<UserStoryModel>? stories,
    UserStoryModel? ownStory,
  }) {
    return StoryState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isCreating: isCreating ?? this.isCreating,
      error: error,
      createdStory: createdStory ?? this.createdStory,
      updatedStory: updatedStory ?? this.updatedStory,
      deletedStoryId: deletedStoryId ?? this.deletedStoryId,
      savePath: savePath ?? this.savePath,
      uploadUrl: uploadUrl ?? this.uploadUrl,
      stories: stories ?? this.stories,
      ownStory: ownStory ?? this.ownStory,
      uploadingFiles: uploadingFiles ?? this.uploadingFiles,
    );
  }
}
