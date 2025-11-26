import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:eefood/features/post/data/models/story_reaction_model.dart';
import 'package:eefood/features/post/domain/repositories/story_reaction_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoryReactionStatsState {
  final List<StoryReactionModel> reactions;
  final Map<ReactionType, int> reactionCounts;
  final int totalReactions;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final int currentPage;
  final int? storyId;

  StoryReactionStatsState({
    this.reactions = const [],
    this.reactionCounts = const {},
    this.totalReactions = 0,
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.currentPage = 1,
    this.storyId,
  });

  StoryReactionStatsState copyWith({
    List<StoryReactionModel>? reactions,
    Map<ReactionType, int>? reactionCounts,
    int? totalReactions,
    bool? isLoading,
    bool? hasMore,
    String? error,
    int? currentPage,
    int? storyId,
  }) {
    return StoryReactionStatsState(
      reactions: reactions ?? this.reactions,
      reactionCounts: reactionCounts ?? this.reactionCounts,
      totalReactions: totalReactions ?? this.totalReactions,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      storyId: storyId ?? this.storyId,
    );
  }
}

class StoryReactionStatsCubit extends Cubit<StoryReactionStatsState> {
  final StoryReactionRepository repository = getIt<StoryReactionRepository>();

  StoryReactionStatsCubit() : super(StoryReactionStatsState());

  Future<void> loadReactions({
    required int storyId,
    bool loadMore = false,
  }) async {
    if (isClosed) return;
    if (!loadMore && state.storyId != storyId) {
      emit(StoryReactionStatsState(storyId: storyId, isLoading: true));
    } else {
      if (state.isLoading) return;
      if (loadMore && !state.hasMore) return;
      emit(state.copyWith(isLoading: true, error: null));
    }

    final page = loadMore ? state.currentPage + 1 : 1;

    try {
      final result = await repository.getUserReactedStory(
        storyId,
        page: page,
        limit: 5,
      );

      if (isClosed) return;

      final newReactions = loadMore
          ? [...state.reactions, ...result.reactions]
          : result.reactions;

      final counts = <ReactionType, int>{};
      for (var reaction in newReactions) {
        counts[reaction.reactionType] =
            (counts[reaction.reactionType] ?? 0) + 1;
      }

      emit(
        state.copyWith(
          reactions: newReactions,
          reactionCounts: counts,
          totalReactions: result.totalElements,
          isLoading: false,
          hasMore: newReactions.length < result.totalElements,
          currentPage: page,
          storyId: storyId
        ),
      );
    } catch (e) {
      if (isClosed) return;
      print('Error loading reactions: $e');
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void reset() {
    if (!isClosed) {
      emit(StoryReactionStatsState());
    }
  }

  void incrementReaction(ReactionType type) {
    if (isClosed) return;

    final newCounts = Map<ReactionType, int>.from(state.reactionCounts);
    newCounts[type] = (newCounts[type] ?? 0) + 1;

    emit(
      state.copyWith(
        reactionCounts: newCounts,
        totalReactions: state.totalReactions + 1,
      ),
    );
  }

  void decrementReaction(ReactionType type) {
    if (isClosed) return;

    final newCounts = Map<ReactionType, int>.from(state.reactionCounts);
    if (newCounts[type] != null && newCounts[type]! > 0) {
      newCounts[type] = newCounts[type]! - 1;
    }

    emit(
      state.copyWith(
        reactionCounts: newCounts,
        totalReactions: state.totalReactions > 0 ? state.totalReactions - 1 : 0,
      ),
    );
  }

}
