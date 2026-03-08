// presentation/provider/watch_live_cubit.dart
import 'dart:developer' as developer;

import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/livestream/data/model/live_stream_response.dart';
import 'package:eefood/features/livestream/data/model/livestream_end_mesage.dart';
import 'package:eefood/features/livestream/domain/repository/live_repository.dart';
import 'package:eefood/features/livestream/presentation/provider/livestream_websocket_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart';

import 'watch_live_state.dart';

class WatchLiveCubit extends Cubit<WatchLiveState> {
  final LiveRepository repository;
  final LiveStreamWebSocketManager _wsManager =
  getIt<LiveStreamWebSocketManager>();

  EventsListener<RoomEvent>? _listener;
  int? _currentStreamId;

  WatchLiveCubit(this.repository) : super(WatchLiveState());

  void _safeEmit(WatchLiveState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> loadLive(int id) async {
    try {
      _safeEmit(state.copyWith(
        loading: true,
        error: null,
        isStreamEnded: false,
        streamEndMessage: null,
      ));

      // Nếu đang nghe stream cũ thì cleanup trước
      _cleanupCurrentWsSubscriptions();

      final res = await repository.getLiveStream(id);
      developer.log('Loaded stream: ${res.roomName}', name: 'WatchLive');

      _currentStreamId = id;

      _safeEmit(state.copyWith(
        loading: false,
        stream: res,
      ));

      _setupWebSocket(id);

      await connectToRoom(res);
    } catch (e) {
      developer.log('Error loading stream: $e', name: 'WatchLive');
      _safeEmit(state.copyWith(
        loading: false,
        error: e.toString(),
      ));
    }
  }

  void _setupWebSocket(int liveStreamId) {
    try {
      _wsManager.connect(
        logName: 'WatchLive',
        onError: (error) {
          developer.log('WS Error: $error', name: 'WatchLive');
          _safeEmit(state.copyWith(error: error));
        },
        onConnected: () {
          _subscribeToStreamEnd(liveStreamId);
        },
      );
    } catch (e) {
      developer.log('Error setting up WebSocket: $e', name: 'WatchLive');
      _safeEmit(state.copyWith(error: e.toString()));
    }
  }

  void _subscribeToStreamEnd(int liveStreamId) {
    _wsManager.subscribeTopic<LiveStreamEndMessage>(
      liveStreamId: liveStreamId,
      topic: 'livestream',
      fromJson: LiveStreamEndMessage.fromJson,
      onData: _handleStreamEnded,
      logName: 'WatchLive',
      logPrefix: 'stream-end-broadcast',
      onError: (error) {
        developer.log('WS Topic Error: $error', name: 'WatchLive');
        _safeEmit(state.copyWith(error: error));
      },
    );

    _wsManager.subscribeUserQueue<LiveStreamEndMessage>(
      queue: 'livestream',
      fromJson: LiveStreamEndMessage.fromJson,
      onData: _handleStreamEnded,
      logName: 'WatchLive',
      logPrefix: 'stream-end-user',
      onError: (error) {
        developer.log('WS User Queue Error: $error', name: 'WatchLive');
        _safeEmit(state.copyWith(error: error));
      },
    );
  }

  void _cleanupCurrentWsSubscriptions() {
    final streamId = _currentStreamId;
    if (streamId == null) return;

    _wsManager.unsubscribeTopic(
      liveStreamId: streamId,
      topic: 'livestream',
      logName: 'WatchLive',
    );

    _wsManager.unsubscribeUserQueue(
      queue: 'livestream',
      logName: 'WatchLive',
    );
  }

  void _handleStreamEnded(LiveStreamEndMessage message) async {
    developer.log('Stream ended: ${message.message}', name: 'WatchLive');

    if (message.type == 'STREAM_ENDED') {
      await disconnect();

      _safeEmit(state.copyWith(
        isStreamEnded: true,
        streamEndMessage: message.message,
        isConnected: false,
        isConnecting: false,
      ));
    }
  }

  Future<void> connectToRoom(LiveStreamResponse stream) async {
    if (state.isConnected || state.isConnecting) {
      developer.log('Already connected or connecting', name: 'WatchLive');
      return;
    }

    developer.log('Connecting to room...', name: 'WatchLive');
    _safeEmit(state.copyWith(isConnecting: true));

    try {
      final room = Room(
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
        ),
      );

      _listener = room.createListener();

      _listener!
        ..on<ParticipantConnectedEvent>((event) {
          developer.log(
            'Participant connected: ${event.participant.identity}',
            name: 'WatchLive',
          );
          _handleRemoteParticipant(event.participant);
        })
        ..on<TrackSubscribedEvent>((event) {
          developer.log(
            'Track subscribed: ${event.track.kind}',
            name: 'WatchLive',
          );

          if (event.track is RemoteVideoTrack) {
            _safeEmit(state.copyWith(
              remoteVideoTrack: event.track as RemoteVideoTrack,
            ));
          } else if (event.track is RemoteAudioTrack) {
            _safeEmit(state.copyWith(
              remoteAudioTrack: event.track as RemoteAudioTrack,
            ));
          }
        })
        ..on<TrackUnsubscribedEvent>((event) {
          developer.log(
            'Track unsubscribed: ${event.track.kind}',
            name: 'WatchLive',
          );

          if (event.track is RemoteVideoTrack) {
            _safeEmit(state.copyWith(remoteVideoTrack: null));
          } else if (event.track is RemoteAudioTrack) {
            _safeEmit(state.copyWith(remoteAudioTrack: null));
          }
        })
        ..on<RoomDisconnectedEvent>((event) {
          developer.log(
            'Room disconnected: ${event.reason}',
            name: 'WatchLive',
          );

          _safeEmit(state.copyWith(
            isConnected: false,
            isConnecting: false,
          ));
        });

      await room.connect(
        AppKeys.livekitUrl,
        stream.livekitToken!,
        connectOptions: const ConnectOptions(autoSubscribe: true),
      );

      developer.log(
        'Connected! State: ${room.connectionState}',
        name: 'WatchLive',
      );

      _safeEmit(state.copyWith(
        room: room,
        isConnected: true,
        isConnecting: false,
      ));

      await Future.delayed(const Duration(seconds: 2));

      for (final participant in room.remoteParticipants.values) {
        _handleRemoteParticipant(participant);
      }
    } catch (e, stackTrace) {
      developer.log(
        'Connection error',
        name: 'WatchLive',
        error: e,
        stackTrace: stackTrace,
      );

      _safeEmit(state.copyWith(
        isConnecting: false,
        error: 'Lỗi kết nối: $e',
      ));
    }
  }

  void _handleRemoteParticipant(RemoteParticipant participant) {
    developer.log(
      'Handling participant: ${participant.identity}',
      name: 'WatchLive',
    );

    participant.addListener(() {
      for (final pub in participant.videoTrackPublications) {
        if (pub.track != null && pub.subscribed && !pub.muted) {
          if (state.remoteVideoTrack != pub.track) {
            _safeEmit(state.copyWith(
              remoteVideoTrack: pub.track as RemoteVideoTrack,
            ));
          }
        }
      }

      for (final pub in participant.audioTrackPublications) {
        if (pub.track != null && pub.subscribed) {
          if (state.remoteAudioTrack != pub.track) {
            _safeEmit(state.copyWith(
              remoteAudioTrack: pub.track as RemoteAudioTrack,
            ));
          }
        }
      }
    });

    for (final pub in participant.videoTrackPublications) {
      if (pub.track != null && pub.subscribed) {
        _safeEmit(state.copyWith(
          remoteVideoTrack: pub.track as RemoteVideoTrack,
        ));
      }
    }

    for (final pub in participant.audioTrackPublications) {
      if (pub.track != null && pub.subscribed) {
        _safeEmit(state.copyWith(
          remoteAudioTrack: pub.track as RemoteAudioTrack,
        ));
      }
    }
  }

  Future<void> disconnect() async {
    _listener?.dispose();
    _listener = null;

    await state.room?.disconnect();
    await state.room?.dispose();

    _safeEmit(state.copyWith(
      room: null,
      isConnected: false,
      isConnecting: false,
      remoteVideoTrack: null,
      remoteAudioTrack: null,
    ));
  }

  @override
  Future<void> close() async {
    _cleanupCurrentWsSubscriptions();
    await disconnect();
    return super.close();
  }
}