import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:eefood/core/constants/app_keys.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

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
  final SharedPreferences _prefs;
  final int liveStreamId;
  StompClient? _stompClient;
  LiveReactionCubit(this._repository, this._prefs, this.liveStreamId) : super(const LiveReactionState()){
    developer.log(
      'LiveReactionCubit created for stream $liveStreamId',
      name: 'LiveReaction',
    );
    // Auto connect WebSocket ngay khi khởi tạo
    connectWebSocket();
  }

  void connectWebSocket() {
    // Check nếu đã connect rồi thì return
    if (_stompClient?.connected == true) {
      developer.log(
        'Already connected to stream $liveStreamId',
        name: 'LiveReaction',
      );
      return;
    }

    final token = _prefs.getString(AppKeys.accessToken) ?? '';

    developer.log(
      'Connecting to WebSocket for stream $liveStreamId',
      name: 'LiveReaction',
    );

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: '${AppKeys.baseUrl}/ws-reaction?token=$token',
        // stompConnectHeaders: {'Authorization': 'Bearer $token'},
        // webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
        onConnect: _onWebSocketConnected,
        onWebSocketError: (err) {
          developer.log('WS error: $err', name: 'LiveReaction');
          emit(state.copyWith(error: 'WebSocket error: $err'));
        },
        onStompError: (frame) {
          developer.log('STOMP error: ${frame.body}', name: 'LiveReaction');
        },
        onDisconnect: (frame) {
          developer.log(
            'Disconnected from stream $liveStreamId',
            name: 'LiveReaction',
          );
        },
      ),
    );

    _stompClient!.activate();

  }

  void _onWebSocketConnected(StompFrame frame) {
    developer.log(
      '[WebSocket] Connected to stream $liveStreamId',
      name: 'LiveReaction',
    );

    // Subscribe vào topic reaction của livestream này
    final destination = '/topic/live-reaction/$liveStreamId';

    _stompClient?.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final json = jsonDecode(frame.body!);
            final reaction = LiveReactionResponse.fromJson(
              Map<String, dynamic>.from(json),
            );

            developer.log(
              'Received reaction: ${reaction.emotion} from ${reaction.username}',
              name: 'LiveReaction',
            );

            // Emit reaction mới - chỉ giữ 1 reaction để trigger animation
            emit(state.copyWith(reactions: [reaction]));

          } catch (e) {
            developer.log(
              'Error parsing reaction: $e',
              name: 'LiveReaction',
            );
          }
        }
      },
    );

    developer.log('Subscribed to: $destination', name: 'LiveReaction');
  }

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
      // final updatedReactions = [...state.reactions, newReaction];
      // final updatedReactions = [newReaction];
      // emit(state.copyWith(reactions: updatedReactions));

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
    developer.log(
      'Closing LiveReactionCubit for stream $liveStreamId',
      name: 'LiveReaction',
    );
    _stompClient?.deactivate();
    return super.close();
  }
}