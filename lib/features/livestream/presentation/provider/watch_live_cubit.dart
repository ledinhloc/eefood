// presentation/provider/watch_live_cubit.dart
import 'package:eefood/features/livestream/data/model/live_stream_response.dart';
import 'package:eefood/features/livestream/domain/repository/live_repository.dart';
import 'package:eefood/features/livestream/presentation/provider/livestream_websocket_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart';
import 'dart:developer' as developer;
import '../../../../core/constants/app_keys.dart';
import '../../data/model/livestream_end_mesage.dart';
import 'watch_live_state.dart';

class WatchLiveCubit extends Cubit<WatchLiveState> {
  final LiveRepository repository;
  late final LiveStreamWebSocketManager _wsManager;
  EventsListener<RoomEvent>? _listener;
  int? _currentStreamId;

  WatchLiveCubit(
      this.repository,
      ) : super(WatchLiveState());

  void _safeEmit(WatchLiveState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> loadLive(int id) async {
    try {
      _safeEmit(state.copyWith(loading: true));

      final res = await repository.getLiveStream(id);
      developer.log('Loaded stream: ${res.roomName}', name: 'WatchLive');

      _safeEmit(state.copyWith(loading: false, stream: res));

      // Setup WebSocket
      _setupWebSocket(id);
      _currentStreamId = id;

      // Connect to LiveKit room
      await connectToRoom(res);
    } catch (e) {
      developer.log('Error loading stream: $e', name: 'WatchLive');
      _safeEmit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  /// Setup WebSocket
  void _setupWebSocket(int liveStreamId) {
    try {
      _wsManager = LiveStreamWebSocketManager(
        liveStreamId: liveStreamId,
        logName: 'WatchLive',
        onError: (error) {
          developer.log('WS Error: $error', name: 'WatchLive');
          _safeEmit(state.copyWith(error: error));
        },
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
      logPrefix: 'stream-end-broadcast',
    );

    _wsManager.subscribeUserQueue<LiveStreamEndMessage>(
      queue: 'livestream',
      fromJson: LiveStreamEndMessage.fromJson,
      onData: _handleStreamEnded,
      logPrefix: 'stream-end-user',
    );
  }

  void _handleStreamEnded(LiveStreamEndMessage message) async {
    developer.log('Stream ended: ${message.message}', name: 'WatchLive');

    if (message.type == 'STREAM_ENDED') {
      await disconnect();
      _safeEmit(state.copyWith(
        isStreamEnded: true,
        streamEndMessage: message.message,
      ));
    }
  }

  /// Connect to LiveKit room
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

      // Setup event listeners
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
          developer.log('Track unsubscribed: ${event.track.kind}', name: 'WatchLive');

          if (event.track is RemoteVideoTrack) {
            _safeEmit(state.copyWith(remoteVideoTrack: null));
          }
        })
        ..on<RoomDisconnectedEvent>((event) {
          developer.log('Room disconnected: ${event.reason}', name: 'WatchLive');
          _safeEmit(state.copyWith(
            isConnected: false,
            isConnecting: false,
          ));
        });

      // Connect
      await room.connect(
        AppKeys.livekitUrl,
        stream.livekitToken!,
        connectOptions: const ConnectOptions(autoSubscribe: true),
      );

      developer.log('Connected! State: ${room.connectionState}', name: 'WatchLive');

      _safeEmit(state.copyWith(
        room: room,
        isConnected: true,
        isConnecting: false,
      ));

      // Wait for tracks
      await Future.delayed(const Duration(seconds: 2));

      // Handle existing participants
      for (var participant in room.remoteParticipants.values) {
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
    developer.log('Handling participant: ${participant.identity}', name: 'WatchLive');

    // Add listener
    participant.addListener(() {
      for (var pub in participant.videoTrackPublications) {
        if (pub.track != null && pub.subscribed && !pub.muted) {
          if (state.remoteVideoTrack != pub.track) {
            _safeEmit(state.copyWith(
              remoteVideoTrack: pub.track as RemoteVideoTrack,
            ));
          }
        }
      }

      for (var pub in participant.audioTrackPublications) {
        if (pub.track != null && pub.subscribed) {
          if (state.remoteAudioTrack != pub.track) {
            _safeEmit(state.copyWith(
              remoteAudioTrack: pub.track as RemoteAudioTrack,
            ));
          }
        }
      }
    });

    // Check existing tracks
    for (var pub in participant.videoTrackPublications) {
      if (pub.track != null && pub.subscribed) {
        _safeEmit(state.copyWith(
          remoteVideoTrack: pub.track as RemoteVideoTrack,
        ));
      }
    }

    for (var pub in participant.audioTrackPublications) {
      if (pub.track != null && pub.subscribed) {
        _safeEmit(state.copyWith(
          remoteAudioTrack: pub.track as RemoteAudioTrack,
        ));
      }
    }
  }

  /// Disconnect room
  Future<void> disconnect() async {
    _listener?.dispose();
    await state.room?.disconnect();
    await state.room?.dispose();
  }

  @override
  Future<void> close() async {
    _wsManager.disconnect();
    await disconnect();
    return super.close();
  }
}