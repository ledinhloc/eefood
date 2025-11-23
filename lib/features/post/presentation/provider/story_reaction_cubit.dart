import 'package:eefood/core/di/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eefood/features/post/domain/repositories/story_reaction_repository.dart';
import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:eefood/features/post/data/models/story_reaction_model.dart';

class StoryReactionState {
  final StoryReactionModel? reaction;
  final bool isLoading;
  final String? error;

  StoryReactionState({this.reaction, this.isLoading = false, this.error});

  StoryReactionState copyWith({
    StoryReactionModel? reaction,
    bool? isLoading,
    String? error,
  }) {
    return StoryReactionState(
      reaction: reaction ?? this.reaction,
      isLoading: isLoading ?? this.isLoading,
      error: error,
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

  Future<void> reactToStory(int storyId, ReactionType type) async {
    if (isClosed) return;

    emit(state.copyWith(isLoading: true, error: null));

    try {
      final result = await repository.reactToStory(storyId, type);
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, reaction: result));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
