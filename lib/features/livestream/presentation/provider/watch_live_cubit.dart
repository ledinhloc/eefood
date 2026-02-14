import 'package:eefood/features/livestream/data/model/live_stream_response.dart';
import 'package:eefood/features/livestream/domain/repository/live_repository.dart';
import 'package:eefood/features/livestream/presentation/provider/livestream_websocket_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import '../../../../core/di/injection.dart';
import '../../data/model/livestream_end_mesage.dart';
import 'watch_live_state.dart';

class WatchLiveCubit extends Cubit<WatchLiveState> {
  final LiveRepository repository;
  late final LiveStreamWebSocketManager _wsManager;
  int? _currentStreamId;

  WatchLiveCubit(
      this.repository,
      ) : super(WatchLiveState()) {
    // WebSocket manager sẽ được init khi loadLive
  }

  Future<void> loadLive(int id) async {
    try {
      emit(WatchLiveState(loading: true));

      final res = await repository.getLiveStream(id);

      developer.log('Loaded stream: ${res.roomName}', name: 'WatchLive');

      emit(WatchLiveState(stream: res));

      _setupWebSocket(id);
      _currentStreamId = id;
    } catch (e) {
      developer.log('Error loading stream: $e', name: 'WatchLive');
      emit(WatchLiveState(error: e.toString()));
    }
  }

  /// Setup WebSocket để listen stream end event
  void _setupWebSocket(int liveStreamId) {
    try {
      _wsManager = LiveStreamWebSocketManager(
        liveStreamId: liveStreamId,
        logName: 'WatchLive',
        onError: (error) => developer.log('WS Error: $error', name: 'WatchLive'),
        onConnected: () => _subscribeToStreamEnd(),
      );

      _wsManager.connect();
    } catch (e) {
      developer.log('Error setting up WebSocket: $e', name: 'WatchLive');
    }
  }

  void _subscribeToStreamEnd() {
    _wsManager.subscribe<LiveStreamEndMessage>(
      topic: 'livestream',
      fromJson: LiveStreamEndMessage.fromJson,
      onData: _handleStreamEnded,
      logPrefix: 'stream-end',
    );
  }

  /// Handle khi stream kết thúc
  void _handleStreamEnded(LiveStreamEndMessage message) {
    developer.log(
      'Stream ended: ${message.message}',
      name: 'WatchLive',
    );

    if (message.type == 'STREAM_ENDED') {
      emit(state.copyWith(
        isStreamEnded: true,
        streamEndMessage: message.message,
      ));
    }
  }

  @override
  Future<void> close() {
    _wsManager.disconnect();
    return super.close();
  }
}