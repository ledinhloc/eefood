import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/post/data/models/story_view_model.dart';
import 'package:eefood/features/post/domain/repositories/story_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoryViewerCubit extends Cubit<StoryViewerState> {
  final StoryRepository repository = getIt<StoryRepository>();

  // Lưu viewers theo storyId
  final Map<int, StoryViewerState> _storyCache = {};

  StoryViewerCubit() : super(StoryViewerState.initial());

  Future<void> loadViewer({
    required int storyId,
    bool loadMore = false,
    bool forceReload = false,
  }) async {
    if (isClosed) return;

    if (forceReload) {
      _storyCache.remove(storyId);
    }

    final cachedState = _storyCache[storyId] ?? StoryViewerState.initial();

    final isDifferentStory =
        state.currentStoryId != null && state.currentStoryId != storyId;

    if (!loadMore && !forceReload && cachedState.viewers.isNotEmpty) {
      emit(cachedState.copyWith(currentStoryId: storyId));
      return;
    }

    if (cachedState.isLoading || (loadMore && !cachedState.hasMore)) return;

    emit(cachedState.copyWith(isLoading: true, currentStoryId: storyId));

    final nextPage = (loadMore && !isDifferentStory)
        ? cachedState.currentPage + 1
        : 1;

    try {
      final pageData = await repository.loadViewer(
        storyId,
        page: nextPage,
        limit: 5,
      );

      print('Độ dài mảng người xem: ${pageData.viewers.length}');

      if (isClosed) return;

      final updatedViewers = loadMore
          ? [...cachedState.viewers, ...pageData.viewers]
          : pageData.viewers;

      if (!loadMore && listEquals(updatedViewers, cachedState.viewers)) {
        return;
      }

      final hasMoreData = updatedViewers.length < pageData.totalElements;

      final newState = cachedState.copyWith(
        isLoading: false,
        viewers: updatedViewers,
        currentPage: nextPage,
        totalElements: pageData.totalElements,
        numberOfElements: pageData.numberOfElements,
        hasMore: hasMoreData,
        currentStoryId: storyId,
      );

      _storyCache[storyId] = newState;
      emit(newState);
    } catch (e) {
      if (!isClosed) {
        if (isDifferentStory || forceReload) {
          emit(
            StoryViewerState.initial().copyWith(
              error: e.toString(),
              currentStoryId: storyId,
            ),
          );
        } else {
          emit(cachedState.copyWith(isLoading: false, error: e.toString()));
        }
      }
    }
  }

  void resetForStory(int storyId) {
    _storyCache.remove(storyId);
  }
}

class StoryViewerState {
  final int? currentStoryId;
  final bool isLoading;
  final List<StoryViewModel> viewers;
  final bool hasMore;
  final int currentPage;
  final int? totalElements;
  final int? numberOfElements;
  final String? error;

  StoryViewerState({
     this.currentStoryId,
    required this.isLoading,
    required this.viewers,
    required this.hasMore,
    required this.currentPage,
    this.totalElements,
    this.numberOfElements,
    this.error,
  });

  factory StoryViewerState.initial() => StoryViewerState(
    isLoading: false,
    viewers: [],
    hasMore: true,
    currentPage: 1,
  );

  StoryViewerState copyWith({
    int? currentStoryId,
    bool? isLoading,
    List<StoryViewModel>? viewers,
    bool? hasMore,
    int? currentPage,
    int? totalElements,
    int? numberOfElements,
    String? error,
  }) => StoryViewerState(
    currentStoryId: currentStoryId ?? this.currentStoryId,
    isLoading: isLoading ?? this.isLoading,
    viewers: viewers ?? this.viewers,
    hasMore: hasMore ?? this.hasMore,
    currentPage: currentPage ?? this.currentPage,
    totalElements: totalElements ?? this.totalElements,
    numberOfElements: numberOfElements ?? this.numberOfElements,
    error: error ?? this.error,
  );
}
