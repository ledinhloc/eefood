import 'package:eefood/features/livestream/data/model/live_stream_response.dart';
import 'package:livekit_client/livekit_client.dart';

class WatchLiveState {
  final bool loading;
  final LiveStreamResponse? stream;
  final String? error;
  final bool isStreamEnded;
  final String? streamEndMessage;

  //  LiveKit room state
  final Room? room;
  final RemoteVideoTrack? remoteVideoTrack;
  final RemoteAudioTrack? remoteAudioTrack;
  final bool isConnected;
  final bool isConnecting;

  WatchLiveState({
    this.loading = false,
    this.stream,
    this.error,
    this.isStreamEnded = false,
    this.streamEndMessage,
    this.room,
    this.remoteVideoTrack,
    this.remoteAudioTrack,
    this.isConnected = false,
    this.isConnecting = false,
  });

  WatchLiveState copyWith({
    bool? loading,
    LiveStreamResponse? stream,
    String? error,
    bool? isStreamEnded,
    String? streamEndMessage,
    Room? room,
    RemoteVideoTrack? remoteVideoTrack,
    RemoteAudioTrack? remoteAudioTrack,
    bool? isConnected,
    bool? isConnecting,
    bool clearStream = false,
    bool clearError = false,
    bool clearStreamEndMessage = false,
    bool clearRoom = false,
    bool clearRemoteVideoTrack = false,
    bool clearRemoteAudioTrack = false,
  }) {
    return WatchLiveState(
      loading: loading ?? this.loading,
      stream: clearStream ? null : (stream ?? this.stream),
      error: clearError ? null : error,
      isStreamEnded: isStreamEnded ?? this.isStreamEnded,
      streamEndMessage: clearStreamEndMessage
          ? null
          : (streamEndMessage ?? this.streamEndMessage),
      room: clearRoom ? null : (room ?? this.room),
      remoteVideoTrack: clearRemoteVideoTrack
          ? null
          : (remoteVideoTrack ?? this.remoteVideoTrack),
      remoteAudioTrack: clearRemoteAudioTrack
          ? null
          : (remoteAudioTrack ?? this.remoteAudioTrack),
      isConnected: isConnected ?? this.isConnected,
      isConnecting: isConnecting ?? this.isConnecting,
    );
  }
}
