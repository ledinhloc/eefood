import 'package:livekit_client/livekit_client.dart';

class LiveStreamState {
  final Room? room;
  final LocalVideoTrack? localVideoTrack;
  final LocalAudioTrack? localAudioTrack;
  final bool isCameraOn;
  final bool isMicOn;
  final bool isFrontCamera;
  final bool isFlashOn;
  final bool isConnected;
  final String? error;
  final int viewerCount;

  LiveStreamState({
    this.room,
    this.localVideoTrack,
    this.localAudioTrack,
    this.isCameraOn = true,
    this.isMicOn = true,
    this.isFrontCamera = true,
    this.isFlashOn = false,
    this.isConnected = false,
    this.error,
    this.viewerCount = 0,
  });

  LiveStreamState copyWith({
    Room? room,
    LocalVideoTrack? localVideoTrack,
    LocalAudioTrack? localAudioTrack,
    bool? isCameraOn,
    bool? isMicOn,
    bool? isFrontCamera,
    bool? isFlashOn,
    bool? isConnected,
    String? error,
    int? viewerCount,
    bool clearRoom = false,
    bool clearVideoTrack = false,
    bool clearAudioTrack = false,
    bool clearError = false,
  }) {
    return LiveStreamState(
      room: clearRoom ? null : (room ?? this.room),
      localVideoTrack:
          clearVideoTrack ? null : (localVideoTrack ?? this.localVideoTrack),
      localAudioTrack:
          clearAudioTrack ? null : (localAudioTrack ?? this.localAudioTrack),
      isCameraOn: isCameraOn ?? this.isCameraOn,
      isMicOn: isMicOn ?? this.isMicOn,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      isConnected: isConnected ?? this.isConnected,
      error: clearError ? null : error,
      viewerCount: viewerCount ?? this.viewerCount,
    );
  }

  static LiveStreamState initial() => LiveStreamState();
}
