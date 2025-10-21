import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/post/data/models/comment_reaction_model.dart';
import 'package:eefood/features/post/domain/repositories/comment_reaction_repository.dart';

class CommentReactionState {
  final List<CommentReactionModel> reactions;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? errorMessage;

  const CommentReactionState({
    required this.reactions,
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.errorMessage,
  });

  CommentReactionState copyWith({
    List<CommentReactionModel>? reactions,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
  }) {
    return CommentReactionState(
      reactions: reactions ?? this.reactions,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage,
    );
  }
}

class CommentReactionCubit extends Cubit<CommentReactionState> {
  final CommentReactionRepository _repository =
      getIt<CommentReactionRepository>();

  CommentReactionCubit()
    : super(
        const CommentReactionState(
          reactions: [],
          currentPage: 1,
          hasMore: true,
          isLoading: false,
        ),
      );

  Future<void> fetchReactions(int commentId, {bool loadMore = false}) async {
    if (state.isLoading || (!state.hasMore && loadMore)) return;

    emit(state.copyWith(isLoading: true, errorMessage: null));

    final nextPage = loadMore ? state.currentPage + 1 : 1;

    try {
      final reactions = await _repository.getReactionAndUserByComment(
        commentId,
        page: nextPage,
        limit: 10,
      );

      print(reactions);
      print('Reaction length ${reactions.length}');

      emit(
        state.copyWith(
          reactions: loadMore ? [...state.reactions, ...reactions] : reactions,
          isLoading: false,
          hasMore: reactions.length == 10,
          currentPage: nextPage,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
