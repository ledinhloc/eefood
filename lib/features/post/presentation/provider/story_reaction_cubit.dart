import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:eefood/features/post/data/models/story_reaction_model.dart';
import 'package:eefood/features/post/domain/repositories/story_reaction_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoryReactionState {
  final StoryReactionModel? reaction;
  final bool isLoading;
  final String? error;
  final int? storyId;

  StoryReactionState({
    this.reaction,
    this.isLoading = false,
    this.error,
    this.storyId,
  });

  StoryReactionState copyWith({
    StoryReactionModel? reaction,
    bool? isLoading,
    String? error,
    int? storyId,
  }) {
    return StoryReactionState(
      reaction: reaction ?? this.reaction,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      storyId: storyId ?? this.storyId,
    );
  }
}

class StoryReactionCubit extends Cubit<StoryReactionState> {
  final StoryReactionRepository repository = getIt<StoryReactionRepository>();

  StoryReactionCubit() : super(StoryReactionState());

  @override
  Future<void> close() {
    return super.close();
  }

  Future<void> loadReactionForStory(int storyId) async {
    if (isClosed) return;

    emit(state.copyWith(isLoading: true, storyId: storyId));

    try {
      final reaction = await repository.getCurrentUserReaction(storyId);
      debugPrint('Reaction cubit: ${reaction?.reactionType.name}');
      if (isClosed) return;

      emit(
        state.copyWith(reaction: reaction, isLoading: false, storyId: storyId),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> reactToStory(int storyId, ReactionType type) async {
    if (isClosed) return;

    if (state.reaction?.reactionType == type && state.storyId == storyId) {
      return;
    }

    emit(state.copyWith(isLoading: true, error: null, storyId: storyId));

    try {
      final result = await repository.reactToStory(storyId, type);
      if (isClosed) return;
      emit(
        state.copyWith(isLoading: false, reaction: result, storyId: storyId),
      );
      print('Reacted to story $storyId with ${type.name}');
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> removeReaction(int storyId) async {
    if (isClosed) return;

    emit(state.copyWith(isLoading: true, error: null));

    try {
      await repository.removeReaction(storyId);
      if (isClosed) return;

      emit(state.copyWith(isLoading: false, reaction: null, storyId: storyId));

      print('Removed reaction from story $storyId');
    } catch (e) {
      if (isClosed) return;
      print('Failed to remove reaction: $e');
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void reset() {
    if (!isClosed) {
      emit(StoryReactionState());
    }
  }
}
