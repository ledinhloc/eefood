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
import '../../data/model/live_comment_response.dart';

class StreamerReactionState extends Equatable {
  final List<LiveReactionResponse> reactions;
  final bool isLoading;
  final String? error;

  const StreamerReactionState({
    this.reactions = const [],
    this.isLoading = false,
    this.error,
  });

  StreamerReactionState copyWith({
    List<LiveReactionResponse>? reactions,
    bool? isLoading,
    String? error,
  }) {
    return StreamerReactionState(
      reactions: reactions ?? this.reactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [reactions, isLoading, error];
}

// Cubit cho Streamer
class StreamerReactionCubit extends Cubit<StreamerReactionState> {
  final SharedPreferences _prefs;
  final int liveStreamId;

  StompClient? _stompClient;

  // Callback để StreamerCommentCubit nhận comment
  Function(LiveCommentResponse)? onCommentReceived;

  StreamerReactionCubit(this._prefs, this.liveStreamId)
      : super(const StreamerReactionState()) {
    developer.log(
      ' StreamerReactionCubit created for stream $liveStreamId',
      name: 'StreamerReaction',
    );
    connectWebSocket();
  }

  void connectWebSocket() {
    if (_stompClient?.connected == true) {
      developer.log(
        'Already connected to stream $liveStreamId',
        name: 'StreamerReaction',
      );
      return;
    }

    final token = _prefs.getString(AppKeys.accessToken) ?? '';

    developer.log(
      ' Connecting to WebSocket for stream $liveStreamId',
      name: 'StreamerReaction',
    );

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: '${AppKeys.baseUrl}/ws-reaction?token=$token',
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
        onConnect: _onWebSocketConnected,
        onWebSocketError: (err) {
          developer.log(' WS error: $err', name: 'StreamerReaction');
          emit(state.copyWith(error: 'WebSocket error: $err'));
        },
        onStompError: (frame) {
          developer.log(' STOMP error: ${frame.body}', name: 'StreamerReaction');
        },
        onDisconnect: (frame) {
          developer.log(
            '️ Disconnected from stream $liveStreamId',
            name: 'StreamerReaction',
          );
        },
      ),
    );

    _stompClient!.activate();
  }

  void _onWebSocketConnected(StompFrame frame) {
    developer.log(
      ' [WebSocket] Streamer connected to stream $liveStreamId',
      name: 'StreamerReaction',
    );

    // Subscribe reactions
    final reactionDestination = '/topic/live-reaction/$liveStreamId';

    _stompClient?.subscribe(
      destination: reactionDestination,
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final json = jsonDecode(frame.body!);
            final reaction = LiveReactionResponse.fromJson(
              Map<String, dynamic>.from(json),
            );

            developer.log(
              'Streamer received reaction: ${reaction.emotion} from ${reaction.username}',
              name: 'StreamerReaction',
            );

            emit(state.copyWith(reactions: [reaction]));

          } catch (e) {
            developer.log(
              'Error parsing reaction: $e',
              name: 'StreamerReaction',
            );
          }
        }
      },
    );

    developer.log(' Subscribed to: $reactionDestination', name: 'StreamerReaction');

    // Subscribe comments
    final commentDestination = '/topic/live-comment/$liveStreamId';

    _stompClient?.subscribe(
      destination: commentDestination,
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final json = jsonDecode(frame.body!);
            final comment = LiveCommentResponse.fromJson(
              Map<String, dynamic>.from(json),
            );

            developer.log(
              ' Streamer received comment: "${comment.message}" from ${comment.username}',
              name: 'StreamerComment',
            );

            onCommentReceived?.call(comment);

          } catch (e) {
            developer.log(
              'Error parsing comment: $e',
              name: 'StreamerComment',
            );
          }
        }
      },
    );

    developer.log(' Subscribed to: $commentDestination', name: 'StreamerComment');
  }

  @override
  Future<void> close() {
    developer.log(
      'Closing StreamerReactionCubit for stream $liveStreamId',
      name: 'StreamerReaction',
    );
    _stompClient?.deactivate();
    return super.close();
  }
}