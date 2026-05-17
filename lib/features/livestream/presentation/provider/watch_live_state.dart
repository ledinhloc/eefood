import 'package:eefood/features/livestream/data/model/live_stream_response.dart';
import 'package:eefood/features/livestream/data/model/live_subtitle_message.dart';
import 'package:eefood/features/livestream/domain/enum/subtitle_language.dart';
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
  final SubtitleLanguage selectedSubtitleLanguage;
  final LiveSubtitleMessage? latestSubtitle;
  final bool isSubtitleConnected;
  final String? subtitleError;

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
    this.selectedSubtitleLanguage = SubtitleLanguage.vi,
    this.latestSubtitle,
    this.isSubtitleConnected = false,
    this.subtitleError,
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
    SubtitleLanguage? selectedSubtitleLanguage,
    LiveSubtitleMessage? latestSubtitle,
    bool? isSubtitleConnected,
    String? subtitleError,
    bool clearStream = false,
    bool clearError = false,
    bool clearStreamEndMessage = false,
    bool clearRoom = false,
    bool clearRemoteVideoTrack = false,
    bool clearRemoteAudioTrack = false,
    bool clearLatestSubtitle = false,
    bool clearSubtitleError = false,
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
      selectedSubtitleLanguage:
          selectedSubtitleLanguage ?? this.selectedSubtitleLanguage,
      latestSubtitle: clearLatestSubtitle
          ? null
          : (latestSubtitle ?? this.latestSubtitle),
      isSubtitleConnected: isSubtitleConnected ?? this.isSubtitleConnected,
      subtitleError: clearSubtitleError
          ? null
          : (subtitleError ?? this.subtitleError),
    );
  }
}
