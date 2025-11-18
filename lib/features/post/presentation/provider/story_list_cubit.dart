import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/post/data/models/user_story_model.dart';
import 'package:eefood/features/post/domain/repositories/story_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoryCubit extends Cubit<StoryState> {
  final StoryRepository repository = getIt<StoryRepository>();

  StoryCubit() : super(StoryState.initial());

  Future<void> loadStories(int viewerId) async {
    try {
      emit(state.copyWith(isLoading: true));

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
      final feedStories = await repository.getFeed(viewerId);
      print('Feed stories count: ${feedStories.length}');

      // Gộp: ownStory -> feedStory
      final merged = [if (ownStories != null) ownStories, ...feedStories];

      emit(
        state.copyWith(isLoading: false, ownStory: ownStories, stories: merged),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
  
}

class StoryState {
  final bool isLoading;
  final List<UserStoryModel> stories;
  final UserStoryModel? ownStory;
  final String? error;

  StoryState({
    required this.isLoading,
    required this.stories,
    this.ownStory,
    this.error,
  });

  factory StoryState.initial() =>
      StoryState(isLoading: false, stories: [], ownStory: null, error: null);

  StoryState copyWith({
    bool? isLoading,
    List<UserStoryModel>? stories,
    UserStoryModel? ownStory,
    String? error,
  }) {
    return StoryState(
      isLoading: isLoading ?? this.isLoading,
      stories: stories ?? this.stories,
      ownStory: ownStory ?? this.ownStory,
      error: error,
    );
  }
}
