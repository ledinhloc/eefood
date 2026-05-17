import 'dart:developer' as developer;

import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/livestream/data/model/live_subtitle_message.dart';
import 'package:eefood/features/livestream/data/model/live_stream_response.dart';
import 'package:eefood/features/livestream/data/model/livestream_end_mesage.dart';
import 'package:eefood/features/livestream/data/model/subtitle_subscription_request.dart';
import 'package:eefood/features/livestream/domain/enum/subtitle_language.dart';
import 'package:eefood/features/livestream/domain/repository/live_repository.dart';
import 'package:eefood/features/livestream/presentation/provider/livestream_websocket_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart';

import 'watch_live_state.dart';

class WatchLiveCubit extends Cubit<WatchLiveState> {
  static const String _subtitleQueue = 'livestream/subtitles';
  static const String _subtitleRegisterDestination =
      '/app/live/subtitles/register';

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
      await disconnect();

      _safeEmit(state.copyWith(
        loading: true,
        isStreamEnded: false,
        clearError: true,
        clearStreamEndMessage: true,
        clearRemoteVideoTrack: true,
        clearRemoteAudioTrack: true,
        clearLatestSubtitle: true,
        clearSubtitleError: true,
        isSubtitleConnected: false,
      ));

      _cleanupCurrentWsSubscriptions();

      final res = await repository.getLiveStream(id);
      developer.log('Loaded stream: ${res.roomName}', name: 'WatchLive');

      _currentStreamId = id;

      _safeEmit(state.copyWith(
        loading: false,
        stream: res,
        clearError: true,
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
          _subscribeToSubtitles(liveStreamId);
          _registerSubtitle(
            liveStreamId: liveStreamId,
            targetLanguage: state.selectedSubtitleLanguage,
          );
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
    if (streamId != null) {
      _wsManager.unsubscribeTopic(
        liveStreamId: streamId,
        topic: 'livestream',
        logName: 'WatchLive',
      );
    }

    _wsManager.unsubscribeUserQueue(
      queue: 'livestream',
      logName: 'WatchLive',
    );

    _wsManager.unsubscribeUserQueue(
      queue: _subtitleQueue,
      logName: 'WatchLive',
    );
  }

  void _subscribeToSubtitles(int liveStreamId) {
    _wsManager.subscribeUserQueue<LiveSubtitleMessage>(
      queue: _subtitleQueue,
      fromJson: LiveSubtitleMessage.fromJson,
      onData: _handleSubtitleMessage,
      logName: 'WatchLive',
      logPrefix: 'subtitle',
      onError: (error) {
        developer.log('Subtitle queue error: $error', name: 'WatchLive');
        _safeEmit(state.copyWith(
          isSubtitleConnected: false,
          subtitleError: error,
        ));
      },
    );

    _safeEmit(state.copyWith(
      isSubtitleConnected: true,
      clearSubtitleError: true,
    ));

    developer.log(
      'Subscribed subtitle queue for stream $liveStreamId',
      name: 'WatchLive',
    );
  }

  void _handleSubtitleMessage(LiveSubtitleMessage message) {
    final currentStreamId = _currentStreamId;
    if (currentStreamId == null || message.liveStreamId != currentStreamId) {
      developer.log(
        'Ignored subtitle for stream ${message.liveStreamId}',
        name: 'WatchLive',
      );
      return;
    }

    if (message.targetLanguage != state.selectedSubtitleLanguage) {
      developer.log(
        'Ignored subtitle for language ${message.targetLanguage.code}',
        name: 'WatchLive',
      );
      return;
    }

    if (message.text.trim().isEmpty) return;

    _safeEmit(state.copyWith(
      latestSubtitle: message,
      clearSubtitleError: true,
      isSubtitleConnected: true,
    ));
  }

  void changeSubtitleLanguage(SubtitleLanguage language) {
    final liveStreamId = _currentStreamId;

    _safeEmit(state.copyWith(
      selectedSubtitleLanguage: language,
      clearLatestSubtitle: true,
      clearSubtitleError: true,
    ));

    if (liveStreamId == null) return;

    if (_wsManager.isConnected) {
      _registerSubtitle(
        liveStreamId: liveStreamId,
        targetLanguage: language,
      );
      return;
    }

    _setupWebSocket(liveStreamId);
  }

  void _registerSubtitle({
    required int liveStreamId,
    required SubtitleLanguage targetLanguage,
  }) {
    final request = SubtitleSubscriptionRequest(
      liveStreamId: liveStreamId,
      targetLanguage: targetLanguage,
    );

    final sent = _wsManager.send(
      destination: _subtitleRegisterDestination,
      body: request.toJson(),
      logName: 'WatchLive',
      onError: (error) {
        developer.log('Subtitle register error: $error', name: 'WatchLive');
        _safeEmit(state.copyWith(
          isSubtitleConnected: false,
          subtitleError: error,
        ));
      },
    );

    if (sent) {
      _safeEmit(state.copyWith(
        isSubtitleConnected: true,
        clearSubtitleError: true,
      ));
    }
  }

  Future<void> _handleStreamEnded(LiveStreamEndMessage message) async {
    developer.log('Stream ended: ${message.message}', name: 'WatchLive');

    if (message.type == 'STREAM_ENDED') {
      await disconnect();

      _safeEmit(state.copyWith(
        isStreamEnded: true,
        streamEndMessage: message.message,
        isConnected: false,
        isConnecting: false,
        isSubtitleConnected: false,
      ));
    }
  }

  Future<void> connectToRoom(LiveStreamResponse stream) async {
    if (state.isConnected || state.isConnecting) {
      developer.log('Already connected or connecting', name: 'WatchLive');
      return;
    }

    developer.log('Connecting to room...', name: 'WatchLive');
    _safeEmit(state.copyWith(
      isConnecting: true,
      clearError: true,
      clearRemoteVideoTrack: true,
      clearRemoteAudioTrack: true,
    ));

    try {
      final room = Room(
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
        ),
      );

      _listener = room.createListener()
        ..on<ParticipantConnectedEvent>((event) {
          developer.log(
            'Participant connected: ${event.participant.identity}',
            name: 'WatchLive',
          );
          _syncParticipantTracks(event.participant);
        })
        ..on<TrackPublishedEvent>((event) {
          developer.log(
            'Track published: ${event.publication.kind}',
            name: 'WatchLive',
          );
          _syncParticipantTracks(event.participant);
        })
        ..on<TrackSubscribedEvent>((event) {
          developer.log(
            'Track subscribed: ${event.track.kind}',
            name: 'WatchLive',
          );
          _syncParticipantTracks(event.participant);
        })
        ..on<TrackUnpublishedEvent>((event) {
          developer.log(
            'Track unpublished: ${event.publication.kind}',
            name: 'WatchLive',
          );
          _syncParticipantTracks(event.participant);
        })
        ..on<TrackUnsubscribedEvent>((event) {
          developer.log(
            'Track unsubscribed: ${event.track.kind}',
            name: 'WatchLive',
          );
          _syncParticipantTracks(event.participant);
        })
        ..on<TrackMutedEvent>((event) {
          developer.log(
            'Track muted: ${event.publication.kind}',
            name: 'WatchLive',
          );
          final participant = event.participant;
          if (participant is RemoteParticipant) {
            _syncParticipantTracks(participant);
          }
        })
        ..on<TrackUnmutedEvent>((event) {
          developer.log(
            'Track unmuted: ${event.publication.kind}',
            name: 'WatchLive',
          );
          final participant = event.participant;
          if (participant is RemoteParticipant) {
            _syncParticipantTracks(participant);
          }
        })
        ..on<ParticipantDisconnectedEvent>((event) {
          developer.log(
            'Participant disconnected: ${event.participant.identity}',
            name: 'WatchLive',
          );
          _syncAllRemoteParticipants(room);
        })
        ..on<RoomDisconnectedEvent>((event) {
          developer.log(
            'Room disconnected: ${event.reason}',
            name: 'WatchLive',
          );
          _safeEmit(state.copyWith(
            isConnected: false,
            isConnecting: false,
            clearRoom: true,
            clearRemoteVideoTrack: true,
            clearRemoteAudioTrack: true,
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
        clearError: true,
      ));

      _syncAllRemoteParticipants(room);
      await Future.delayed(const Duration(milliseconds: 500));
      _syncAllRemoteParticipants(room);
    } catch (e, stackTrace) {
      developer.log(
        'Connection error',
        name: 'WatchLive',
        error: e,
        stackTrace: stackTrace,
      );

      _safeEmit(state.copyWith(
        isConnecting: false,
        error: 'Loi ket noi: $e',
        isSubtitleConnected: false,
      ));
    }
  }

  void _syncAllRemoteParticipants(Room room) {
    if (room.remoteParticipants.isEmpty) {
      _safeEmit(state.copyWith(
        clearRemoteVideoTrack: true,
        clearRemoteAudioTrack: true,
      ));
      return;
    }

    for (final participant in room.remoteParticipants.values) {
      _syncParticipantTracks(participant);
    }
  }

  void _syncParticipantTracks(RemoteParticipant participant) {
    developer.log(
      'Sync participant tracks: ${participant.identity}',
      name: 'WatchLive',
    );

    RemoteVideoTrack? nextVideoTrack;
    RemoteAudioTrack? nextAudioTrack;

    for (final publication in participant.trackPublications.values) {
      final track = publication.track;
      if (track == null || !publication.subscribed || publication.muted) {
        continue;
      }

      if (track is RemoteVideoTrack && nextVideoTrack == null) {
        nextVideoTrack = track;
      } else if (track is RemoteAudioTrack && nextAudioTrack == null) {
        nextAudioTrack = track;
      }
    }

    _safeEmit(state.copyWith(
      remoteVideoTrack: nextVideoTrack,
      remoteAudioTrack: nextAudioTrack,
      clearRemoteVideoTrack: nextVideoTrack == null,
      clearRemoteAudioTrack: nextAudioTrack == null,
    ));
  }

  Future<void> disconnect() async {
    _listener?.dispose();
    _listener = null;

    await state.room?.disconnect();
    await state.room?.dispose();

    _safeEmit(state.copyWith(
      clearRoom: true,
      isConnected: false,
      isConnecting: false,
      clearRemoteVideoTrack: true,
      clearRemoteAudioTrack: true,
      isSubtitleConnected: false,
    ));
  }

  @override
  Future<void> close() async {
    _cleanupCurrentWsSubscriptions();
    await disconnect();
    return super.close();
  }
}
