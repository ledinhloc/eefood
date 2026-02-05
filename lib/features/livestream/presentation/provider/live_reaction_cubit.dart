// presentation/cubit/live_reaction_cubit.dart
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/model/live_reaction_response.dart';
import '../../domain/repository/live_reaction_repo.dart';
import 'live_reaction_state.dart';
import 'livestream_websocket_manager.dart';

class LiveReactionCubit extends Cubit<LiveReactionState> {
  final LiveReactionRepository _repository;
  late final LiveStreamWebSocketManager _wsManager;

  LiveReactionCubit(
      this._repository,
      int liveStreamId,
      ) : super(const LiveReactionState()) {
    _wsManager = LiveStreamWebSocketManager(
      liveStreamId: liveStreamId,
      logName: 'LiveReaction',
      onError: (error) => emit(state.copyWith(error: error)),
      onConnected: _onWebSocketConnected,
    );

    developer.log('LiveReactionCubit created for stream $liveStreamId',
        name: 'LiveReaction');
    _wsManager.connect();
  }

  void _onWebSocketConnected() {
    _wsManager.subscribe<LiveReactionResponse>(
      topic: 'live-reaction',
      fromJson: LiveReactionResponse.fromJson,
      onData: (reaction) {
        developer.log(
          'Received reaction: ${reaction.emotion} from ${reaction.username}',
          name: 'LiveReaction',
        );
        emit(state.copyWith(reactions: [reaction]));
      },
      logPrefix: 'reaction',
    );
  }

  Future<void> createReaction(int liveStreamId, FoodEmotion emotion) async {
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
    _wsManager.disconnect();
    return super.close();
  }
}