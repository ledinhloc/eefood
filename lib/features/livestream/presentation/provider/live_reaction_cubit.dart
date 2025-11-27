import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/model/live_reaction_response.dart';
import '../../domain/repository/live_reaction_repo.dart';

// State
class LiveReactionState extends Equatable {
  final List<LiveReactionResponse> reactions;
  final bool isLoading;
  final String? error;

  const LiveReactionState({
    this.reactions = const [],
    this.isLoading = false,
    this.error,
  });

  LiveReactionState copyWith({
    List<LiveReactionResponse>? reactions,
    bool? isLoading,
    String? error,
  }) {
    return LiveReactionState(
      reactions: reactions ?? this.reactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [reactions, isLoading, error];
}

// Cubit
class LiveReactionCubit extends Cubit<LiveReactionState> {
  final LiveReactionRepository _repository;
  Timer? _pollTimer;

  LiveReactionCubit(this._repository) : super(const LiveReactionState());

  // Load reactions ban đầu
  Future<void> loadReactions(int liveStreamId) async {
    try {
      emit(state.copyWith(isLoading: true));
      final reactions = await _repository.getReactions(liveStreamId);
      emit(state.copyWith(reactions: reactions, isLoading: false));
    } catch (e) {
      developer.log('Error loading reactions: $e', name: 'LiveReaction');
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  // Tạo reaction mới
  Future<void> createReaction(int liveStreamId, FoodEmotion emotion) async {
    try {
      final newReaction = await _repository.createReaction(
        liveStreamId,
        emotion.name,
      );

      // Thêm reaction mới vào danh sách
      final updatedReactions = [...state.reactions, newReaction];
      emit(state.copyWith(reactions: updatedReactions));

      developer.log(
        'Reaction created: ${emotion.name} by ${newReaction.username}',
        name: 'LiveReaction',
      );
    } catch (e) {
      developer.log('Error creating reaction: $e', name: 'LiveReaction');
      emit(state.copyWith(error: e.toString()));
    }
  }

  // Polling reactions mới từ server (optional)
  void startPolling(int liveStreamId, {Duration interval = const Duration(seconds: 3)}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(interval, (_) async {
      try {
        final reactions = await _repository.getReactions(liveStreamId);
        if (!isClosed) {
          emit(state.copyWith(reactions: reactions));
        }
      } catch (e) {
        developer.log('Polling error: $e', name: 'LiveReaction');
      }
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
  }

  @override
  Future<void> close() {
    stopPolling();
    return super.close();
  }
}