import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/model/live_comment_response.dart';
import '../../domain/repository/live_comment_repo.dart';

class StreamerCommentState extends Equatable {
  final List<LiveCommentResponse> comments;
  final int? liveStreamId;
  final String? error;
  final bool loading;

  const StreamerCommentState({
    this.comments = const [],
    this.liveStreamId,
    this.error,
    this.loading = false,
  });

  factory StreamerCommentState.initial() => const StreamerCommentState(
    loading: false,
    comments: [],
  );

  StreamerCommentState copyWith({
    List<LiveCommentResponse>? comments,
    int? liveStreamId,
    String? error,
    bool? loading,
  }) {
    return StreamerCommentState(
      comments: comments ?? this.comments,
      liveStreamId: liveStreamId ?? this.liveStreamId,
      error: error,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [comments, liveStreamId, error, loading];
}

class StreamerCommentCubit extends Cubit<StreamerCommentState> {
  final LiveCommentRepository _commentRepository;

  StreamerCommentCubit(this._commentRepository)
      : super(StreamerCommentState.initial());

  /// Load comments từ API khi bắt đầu live
  Future<void> loadComments(int liveStreamId) async {
    emit(state.copyWith(
      loading: true,
      liveStreamId: liveStreamId,
      error: null,
    ));

    try {
      final comments = await _commentRepository.getComments(liveStreamId);
      emit(state.copyWith(
        comments: comments,
        loading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: 'Lỗi tải bình luận: ${e.toString()}',
      ));
    }
  }

  /// Thêm comment mới (gửi lên server)
  Future<void> addComment(String message) async {
    final id = state.liveStreamId;
    if (id == null) {
      emit(state.copyWith(error: "LiveStream ID chưa được thiết lập"));
      return;
    }

    if (message.trim().isEmpty) return;

    try {
      await _commentRepository.createComment(id, message);

      // Comment sẽ được nhận lại qua WebSocket thông qua addCommentFromWebSocket
    } catch (e) {
      emit(state.copyWith(
        error: 'Lỗi gửi bình luận: ${e.toString()}',
      ));
    }
  }

  void addCommentOptimistic(LiveCommentResponse comment) {
    final updatedComments = List<LiveCommentResponse>.from(state.comments)
      ..add(comment);

    emit(state.copyWith(comments: updatedComments));
  }

  /// Nhận comment từ WebSocket
  void addCommentFromWebSocket(LiveCommentResponse comment) {
    // Check duplicate
    if (state.comments.any((c) => c.id == comment.id)) {
      return;
    }

    final updatedComments = List<LiveCommentResponse>.from(state.comments)
      ..add(comment);

    emit(state.copyWith(comments: updatedComments));

    // Tự động giới hạn comment sau mỗi lần thêm
    // limitComments();
  }

  void limitComments({int maxComments = 50}) {
    if (state.comments.length > maxComments) {
      final limitedComments = state.comments.sublist(
        state.comments.length - maxComments,
      );
      emit(state.copyWith(comments: limitedComments));
    }
  }
}