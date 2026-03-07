// presentation/cubit/live_comment_cubit.dart
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/model/live_comment_response.dart';
import '../../domain/repository/live_comment_repo.dart';
import 'live_comment_state.dart';
import 'livestream_websocket_manager.dart';

class LiveCommentCubit extends Cubit<LiveCommentState> {
  final LiveCommentRepository _repository;
  late final LiveStreamWebSocketManager _wsManager;
  final int liveStreamId;

  LiveCommentCubit(
      this._repository,
      this.liveStreamId,
      ) : super(LiveCommentState.initial()) {
    _wsManager = LiveStreamWebSocketManager(
      liveStreamId: liveStreamId,
      logName: 'LiveComment',
      onError: (error) => emit(state.copyWith(error: error)),
      onConnected: _onWebSocketConnected,
    );

    developer.log('LiveCommentCubit created for stream $liveStreamId',
        name: 'LiveComment');

    // Auto connect và load comments
    _wsManager.connect();
    loadComments();
  }

  void _onWebSocketConnected() {
    _wsManager.subscribe<LiveCommentResponse>(
      topic: 'live-comment',
      fromJson: LiveCommentResponse.fromJson,
      onData: _addCommentFromWebSocket,
      logPrefix: 'comment',
    );
  }

  /// Load comments từ API
  Future<void> loadComments() async {
    emit(state.copyWith(
      loading: true,
      liveStreamId: liveStreamId,
      error: null,
    ));

    try {
      final comments = await _repository.getComments(liveStreamId);
      emit(state.copyWith(comments: comments, loading: false));
    } catch (e) {
      developer.log('Error loading comments: $e', name: 'LiveComment');
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  /// Thêm comment từ WebSocket
  void _addCommentFromWebSocket(LiveCommentResponse comment) {
    developer.log(
      'Received comment: "${comment.message}" from ${comment.username}',
      name: 'LiveComment',
    );

    // Check duplicate
    if (state.comments.any((c) => c.id == comment.id)) {
      developer.log('Duplicate comment ignored: ${comment.id}',
          name: 'LiveComment');
      return;
    }

    final updatedComments = List<LiveCommentResponse>.from(state.comments)
      ..add(comment);

    emit(state.copyWith(comments: updatedComments));

    // Auto limit comments
    _limitComments();
  }

  /// Gửi comment mới
  Future<void> sendComment(String message) async {
    if (message.trim().isEmpty) return;

    try {
      await _repository.createComment(liveStreamId, message);
      developer.log('Comment sent: $message', name: 'LiveComment');

      // Comment sẽ được nhận lại qua WebSocket
    } catch (e) {
      developer.log('Error sending comment: $e', name: 'LiveComment');
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Giới hạn số lượng comment
  void _limitComments({int maxComments = 50}) {
    if (state.comments.length > maxComments) {
      final limitedComments = state.comments.sublist(
        state.comments.length - maxComments,
      );
      emit(state.copyWith(comments: limitedComments));
    }
  }

  @override
  Future<void> close() {
    _wsManager.disconnect();
    return super.close();
  }
}