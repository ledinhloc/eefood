import 'package:equatable/equatable.dart';

import '../../data/model/live_comment_response.dart';
import 'package:bloc/bloc.dart';
import '../../domain/repository/live_comment_repo.dart';

class LiveCommentCubit extends Cubit<LiveCommentState> {
  final LiveCommentRepository repository;
  LiveCommentCubit(this.repository)
      : super(LiveCommentState.initial());

  /// Load comments từ API
  Future<void> loadComments(int liveStreamId) async {
    emit(state.copyWith(loading: true, liveStreamId: liveStreamId, error: null));
    try {
      final comments = await repository.getComments(liveStreamId);
      emit(state.copyWith(comments: comments, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void addCommentFromWebSocket(LiveCommentResponse comment) {
    final updatedComments = List<LiveCommentResponse>.from(state.comments)
      ..add(comment);
    emit(state.copyWith(comments: updatedComments));
  }

  /// Thêm comment mới
  Future<void> addComment(String message) async {
    final id = state.liveStreamId;
    if (id == null) {
      emit(state.copyWith(error: "LiveStream ID not set"));
      return;
    }

    try {
      await repository.createComment(id, message);
      // final updatedComments = List<LiveCommentResponse>.from(state.comments)
      //   ..add(comment);
      // emit(state.copyWith(comments: updatedComments));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}

class LiveCommentState extends Equatable{
  final bool loading;
  final List<LiveCommentResponse> comments;
  final int? liveStreamId;
  final String? error;

  const LiveCommentState({
    required this.loading,
    required this.comments,
    this.liveStreamId,
    this.error,
  });

  factory LiveCommentState.initial() =>
      const LiveCommentState(loading: false, comments: []);

  LiveCommentState copyWith({
    bool? loading,
    List<LiveCommentResponse>? comments,
    int? liveStreamId,
    String? error,
  }) {
    return LiveCommentState(
      loading: loading ?? this.loading,
      comments: comments ?? this.comments,
      liveStreamId: liveStreamId ?? this.liveStreamId,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, comments, liveStreamId, error];
}