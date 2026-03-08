// presentation/cubit/live_reaction_cubit.dart
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../data/model/live_reaction_response.dart';
import '../../domain/repository/live_reaction_repo.dart';
import 'live_reaction_state.dart';
import 'livestream_websocket_manager.dart';

class LiveReactionCubit extends Cubit<LiveReactionState> {
  final LiveReactionRepository _repository;
  final LiveStreamWebSocketManager _wsManager =
  getIt<LiveStreamWebSocketManager>();

  final int liveStreamId;

  LiveReactionCubit(
      this._repository,
      this.liveStreamId,
      ) : super(const LiveReactionState()) {
    developer.log(
      'LiveReactionCubit created for stream $liveStreamId',
      name: 'LiveReaction',
    );

    _setupWebSocket();
  }

  void _setupWebSocket() {
    try {
      _wsManager.connect(
        logName: 'LiveReaction',
        onError: (error) {
          developer.log('WS Error: $error', name: 'LiveReaction');
          if (!isClosed) {
            emit(state.copyWith(error: error));
          }
        },
        onConnected: _onWebSocketConnected,
      );
    } catch (e) {
      developer.log('Error setting up WebSocket: $e', name: 'LiveReaction');
      if (!isClosed) {
        emit(state.copyWith(error: e.toString()));
      }
    }
  }

  void _onWebSocketConnected() {
    _wsManager.subscribeTopic<LiveReactionResponse>(
      liveStreamId: liveStreamId,
      topic: 'live-reaction',
      fromJson: LiveReactionResponse.fromJson,
      onData: _handleReactionFromWebSocket,
      logName: 'LiveReaction',
      logPrefix: 'reaction',
      onError: (error) {
        developer.log('Subscribe error: $error', name: 'LiveReaction');
        if (!isClosed) {
          emit(state.copyWith(error: error));
        }
      },
    );
  }

  void _handleReactionFromWebSocket(LiveReactionResponse reaction) {
    developer.log(
      'Received reaction: ${reaction.emotion} from ${reaction.username}',
      name: 'LiveReaction',
    );

    emit(state.copyWith(
      reactions: [reaction],
    ));
  }

  Future<void> createReaction(FoodEmotion emotion) async {
    try {
      final newReaction = await _repository.createReaction(
        liveStreamId,
        emotion.name,
      );

      developer.log(
        'Reaction created: ${emotion.name} by ${newReaction.username}',
        name: 'LiveReaction',
      );
    } catch (e) {
      developer.log('Error creating reaction: $e', name: 'LiveReaction');
      emit(state.copyWith(error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _wsManager.unsubscribeTopic(
      liveStreamId: liveStreamId,
      topic: 'live-reaction',
      logName: 'LiveReaction',
    );

    return super.close();
  }
}