// presentation/provider/live_viewer_cubit.dart
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../data/model/viewer_model.dart';
import '../../data/model/viewer_update_message.dart';
import '../../domain/repository/live_viewer_repository.dart';
import 'live_viewer_state.dart';
import 'livestream_websocket_manager.dart';

class LiveViewerCubit extends Cubit<LiveViewerState> {
  final LiveViewerRepository _repository;
  final LiveStreamWebSocketManager _wsManager =
      getIt<LiveStreamWebSocketManager>();

  final int liveStreamId;

  LiveViewerCubit(this._repository, this.liveStreamId)
    : super(LiveViewerState.initial()) {
    developer.log(
      'LiveViewerCubit created for stream $liveStreamId',
      name: 'LiveViewer',
    );

    _setupWebSocket();
    loadViewers();
  }

  void _setupWebSocket() {
    try {
      _wsManager.connect(
        logName: 'LiveViewer',
        onError: (error) {
          developer.log('WS Error: $error', name: 'LiveViewer');
          if (!isClosed) {
            emit(state.copyWith(error: error));
          }
        },
        onConnected: _onWebSocketConnected,
      );
    } catch (e) {
      developer.log('Error setting up WebSocket: $e', name: 'LiveViewer');
      if (!isClosed) {
        emit(state.copyWith(error: e.toString()));
      }
    }
  }

  void _onWebSocketConnected() {
    _wsManager.subscribeTopic<ViewerUpdateMessage>(
      liveStreamId: liveStreamId,
      topic: 'viewer-update',
      fromJson: ViewerUpdateMessage.fromJson,
      onData: _handleViewerUpdate,
      logName: 'LiveViewer',
      logPrefix: 'viewer-update',
      onError: (error) {
        developer.log('Subscribe error: $error', name: 'LiveViewer');
        if (!isClosed) {
          emit(state.copyWith(error: error));
        }
      },
    );
  }

  /// Load danh sách viewers từ API
  Future<void> loadViewers() async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final viewers = await _repository.getViewers(liveStreamId);

      developer.log('Loaded ${viewers.length} viewers', name: 'LiveViewer');

      emit(state.copyWith(viewers: viewers, loading: false));
    } catch (e) {
      developer.log('Error loading viewers: $e', name: 'LiveViewer');
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  /// Join livestream
  Future<void> joinLiveStream() async {
    try {
      await _repository.joinLiveStream(liveStreamId);

      developer.log('Joined livestream $liveStreamId', name: 'LiveViewer');
      emit(state.copyWith(isJoined: true));
    } catch (e) {
      developer.log('Error joining livestream: $e', name: 'LiveViewer');
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Leave livestream
  Future<void> leaveLiveStream() async {
    try {
      await _repository.leaveLiveStream(liveStreamId);

      developer.log('Left livestream $liveStreamId', name: 'LiveViewer');
      emit(state.copyWith(isJoined: false));
    } catch (e) {
      developer.log('Error leaving livestream: $e', name: 'LiveViewer');
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Xử lý WebSocket update
  void _handleViewerUpdate(ViewerUpdateMessage message) {
    developer.log(
      'Received viewer update: ${message.type}',
      name: 'LiveViewer',
    );

    if (message.type == 'JOIN' && message.viewer != null) {
      _addViewer(message.viewer!);
    } else if (message.type == 'LEAVE' && message.userId != null) {
      _removeViewer(message.userId!);
    }
  }

  /// Thêm viewer mới
  void _addViewer(ViewerModel viewer) {
    final isDuplicate = state.viewers.any((v) => v.userId == viewer.userId);

    if (isDuplicate) {
      developer.log(
        'Duplicate viewer ignored: ${viewer.userId}',
        name: 'LiveViewer',
      );
      return;
    }

    final updatedViewers = [viewer, ...state.viewers];
    emit(state.copyWith(viewers: updatedViewers));

    developer.log('Added viewer: ${viewer.username}', name: 'LiveViewer');
  }

  /// Xóa viewer
  void _removeViewer(int userId) {
    final updatedViewers = state.viewers
        .where((v) => v.userId != userId)
        .toList();

    emit(state.copyWith(viewers: updatedViewers));

    developer.log('Removed viewer: $userId', name: 'LiveViewer');
  }

  @override
  Future<void> close() {
    _wsManager.unsubscribeTopic(
      liveStreamId: liveStreamId,
      topic: 'viewer-update',
      logName: 'LiveViewer',
    );

    return super.close();
  }
}
