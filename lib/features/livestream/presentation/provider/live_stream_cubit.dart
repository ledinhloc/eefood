// presentation/provider/live_stream_cubit.dart
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart';

import 'live_stream_state.dart';

class LiveStreamCubit extends Cubit<LiveStreamState> {
  LiveStreamCubit() : super(LiveStreamState.initial());

  void _safeEmit(LiveStreamState newState) {
    if (!isClosed) emit(newState);
  }

  void _logTrackState(String event, {LocalTrack? incomingTrack}) {
    final videoTrack = state.localVideoTrack;
    final audioTrack = state.localAudioTrack;

    developer.log(
      [
        'event=$event',
        if (incomingTrack != null)
          'incoming=${incomingTrack.runtimeType}#${incomingTrack.hashCode}',
        'video=${videoTrack == null ? 'null' : '${videoTrack.runtimeType}#${videoTrack.hashCode} enabled=${videoTrack.mediaStreamTrack.enabled}'}',
        'audio=${audioTrack == null ? 'null' : '${audioTrack.runtimeType}#${audioTrack.hashCode} enabled=${audioTrack.mediaStreamTrack.enabled}'}',
        'roomConnected=${state.isConnected}',
      ].join(' | '),
      name: 'LiveStreamTracks',
    );
  }

  void setTracks(LocalVideoTrack videoTrack, LocalAudioTrack audioTrack) {
    _logTrackState(
      'setTracks:before',
      incomingTrack: videoTrack,
    );
    _safeEmit(
      state.copyWith(
        localVideoTrack: videoTrack,
        localAudioTrack: audioTrack,
        isCameraOn: videoTrack.mediaStreamTrack.enabled,
        isMicOn: audioTrack.mediaStreamTrack.enabled,
        clearError: true,
      ),
    );
    _logTrackState('setTracks:after', incomingTrack: audioTrack);
  }

  void setPreviewVideoTrack(LocalVideoTrack videoTrack) {
    _logTrackState(
      'setPreviewVideoTrack:before',
      incomingTrack: videoTrack,
    );
    _safeEmit(
      state.copyWith(
        localVideoTrack: videoTrack,
        isCameraOn: true,
        clearError: true,
      ),
    );
    _logTrackState('setPreviewVideoTrack:after');
  }

  void setAudioTrack(LocalAudioTrack audioTrack) {
    _logTrackState(
      'setAudioTrack:before',
      incomingTrack: audioTrack,
    );
    _safeEmit(
      state.copyWith(
        localAudioTrack: audioTrack,
        clearError: true,
      ),
    );
    _logTrackState('setAudioTrack:after');
  }

  Future<void> connectToRoom(String livekitUrl, String token) async {
    _logTrackState('connectToRoom:start');
    if (state.isConnected && state.room != null) {
      _logTrackState('connectToRoom:skipped-already-connected');
      return;
    }

    if (state.localVideoTrack == null || state.localAudioTrack == null) {
      _logTrackState('connectToRoom:missing-tracks');
      _safeEmit(state.copyWith(error: 'Tracks not initialized'));
      return;
    }

    try {
      final room = Room(
        roomOptions: const RoomOptions(
          dynacast: true,
          defaultCameraCaptureOptions: CameraCaptureOptions(
            params: VideoParametersPresets.h360_169,
            maxFrameRate: 15,
          ),
          defaultAudioCaptureOptions: AudioCaptureOptions(
            noiseSuppression: true,
            echoCancellation: true,
            autoGainControl: false,
          ),
        ),
      );
      await room.connect(livekitUrl, token);

      if (state.localVideoTrack!.mediaStreamTrack.enabled) {
        await room.localParticipant!.publishVideoTrack(state.localVideoTrack!);
      }

      if (state.localAudioTrack!.mediaStreamTrack.enabled) {
        await room.localParticipant!.publishAudioTrack(state.localAudioTrack!);
      }

      _safeEmit(
        state.copyWith(room: room, isConnected: true, clearError: true),
      );
      _logTrackState('connectToRoom:connected');
    } catch (e) {
      _logTrackState('connectToRoom:error');
      _safeEmit(state.copyWith(error: 'Connection error: $e'));
    }
  }

  Future<void> toggleCamera() async {
    _logTrackState('toggleCamera:start');
    if (state.room == null) {
      if (state.localVideoTrack == null) {
        _safeEmit(
          state.copyWith(isCameraOn: !state.isCameraOn, clearError: true),
        );
        _logTrackState('toggleCamera:no-track-flag-only');
        return;
      }

      if (state.isCameraOn) {
        await disposePreviewVideoTrack();
      } else {
        await state.localVideoTrack!.enable();
        _safeEmit(
          state.copyWith(
            isCameraOn: true,
            clearError: true,
          ),
        );
      }
      _logTrackState('toggleCamera:local-only-done');
      return;
    }

    if (state.localVideoTrack == null) return;

    try {
      LocalVideoTrack? nextVideoTrack = state.localVideoTrack;

      if (state.room?.localParticipant != null) {
        final publication = await state.room!.localParticipant!
            .setCameraEnabled(!state.isCameraOn);
        final publishedTrack = publication?.track;
        if (publishedTrack is LocalVideoTrack) {
          nextVideoTrack = publishedTrack;
        }
      } else if (state.isCameraOn) {
        await state.localVideoTrack!.disable();
      } else {
        await state.localVideoTrack!.enable();
      }

      _safeEmit(
        state.copyWith(
          localVideoTrack: nextVideoTrack,
          isCameraOn: !state.isCameraOn,
          clearError: true,
        ),
      );
      _logTrackState('toggleCamera:room-done');
    } catch (e) {
      _logTrackState('toggleCamera:error');
      _safeEmit(state.copyWith(error: 'Error toggling camera: $e'));
    }
  }

  Future<void> toggleMic() async {
    _logTrackState('toggleMic:start');
    if (state.localAudioTrack == null) {
      _safeEmit(state.copyWith(isMicOn: !state.isMicOn, clearError: true));
      _logTrackState('toggleMic:no-track-flag-only');
      return;
    }

    try {
      LocalAudioTrack? nextAudioTrack = state.localAudioTrack;

      if (state.room?.localParticipant != null) {
        final publication = await state.room!.localParticipant!
            .setMicrophoneEnabled(!state.isMicOn);
        final publishedTrack = publication?.track;
        if (publishedTrack is LocalAudioTrack) {
          nextAudioTrack = publishedTrack;
        }
      } else if (state.isMicOn) {
        await state.localAudioTrack!.disable();
      } else {
        await state.localAudioTrack!.enable();
      }

      _safeEmit(
        state.copyWith(
          localAudioTrack: nextAudioTrack,
          isMicOn: !state.isMicOn,
          clearError: true,
        ),
      );
      _logTrackState('toggleMic:done');
    } catch (e) {
      _logTrackState('toggleMic:error');
      _safeEmit(state.copyWith(error: 'Error toggling mic: $e'));
    }
  }

  Future<void> switchCamera() async {
    if (state.localVideoTrack == null) {
      _safeEmit(
        state.copyWith(isFrontCamera: !state.isFrontCamera, clearError: true),
      );
      return;
    }

    try {
      if (state.isFlashOn) {
        await state.localVideoTrack!.mediaStreamTrack.setTorch(false);
        _safeEmit(state.copyWith(isFlashOn: false));
      }

      final newPosition = state.isFrontCamera
          ? CameraPosition.back
          : CameraPosition.front;

      await state.localVideoTrack!.setCameraPosition(newPosition);

      _safeEmit(
        state.copyWith(isFrontCamera: !state.isFrontCamera, clearError: true),
      );
    } catch (e) {
      _safeEmit(state.copyWith(error: 'Error switching camera: $e'));
    }
  }

  Future<void> toggleFlash() async {
    if (state.localVideoTrack == null) return;

    if (state.isFrontCamera) {
      _safeEmit(state.copyWith(error: 'Flash chi hoat dong voi camera sau'));
      return;
    }

    try {
      final mediaTrack = state.localVideoTrack!.mediaStreamTrack;
      final hasTorch = await mediaTrack.hasTorch();
      if (!hasTorch) {
        _safeEmit(
          state.copyWith(
            error: 'Thiet bi nay khong ho tro bat den flash khi livestream',
          ),
        );
        return;
      }

      await mediaTrack.setTorch(!state.isFlashOn);

      _safeEmit(state.copyWith(isFlashOn: !state.isFlashOn, clearError: true));
    } catch (e) {
      _safeEmit(state.copyWith(error: 'Error toggling flash: $e'));
    }
  }

  Future<void> disposeTracksOnly() async {
    _logTrackState('disposeTracksOnly:start');
    await state.localVideoTrack?.stop();
    await state.localVideoTrack?.dispose();
    await state.localAudioTrack?.stop();
    await state.localAudioTrack?.dispose();

    _safeEmit(
      state.copyWith(
        clearVideoTrack: true,
        clearAudioTrack: true,
        isConnected: false,
        isCameraOn: true,
        isMicOn: true,
        isFrontCamera: true,
        isFlashOn: false,
        clearError: true,
      ),
    );
    _logTrackState('disposeTracksOnly:after');
  }

  Future<void> disposePreviewVideoTrack() async {
    _logTrackState('disposePreviewVideoTrack:start');
    await state.localVideoTrack?.stop();
    await state.localVideoTrack?.dispose();

    _safeEmit(
      state.copyWith(
        clearVideoTrack: true,
        isCameraOn: false,
        isFlashOn: false,
        clearError: true,
      ),
    );
    _logTrackState('disposePreviewVideoTrack:after');
  }

  Future<void> disconnect() async {
    _logTrackState('disconnect:start');

    try {
      await state.localVideoTrack?.stop();
    } catch (_) {}
    try {
      await state.localVideoTrack?.dispose();
    } catch (_) {}
    try {
      await state.localAudioTrack?.stop();
    } catch (_) {}
    try {
      await state.localAudioTrack?.dispose();
    } catch (_) {}
    try {
      await state.room?.disconnect();
    } catch (_) {}
    try {
      await state.room?.dispose();
    } catch (_) {}

    _safeEmit(
      state.copyWith(
        clearRoom: true,
        clearVideoTrack: true,
        clearAudioTrack: true,
        isConnected: false,
        isCameraOn: true,
        isMicOn: true,
        isFrontCamera: true,
        isFlashOn: false,
        clearError: true,
      ),
    );
    _logTrackState('disconnect:after');
  }

  @override
  Future<void> close() async {
    await disconnect();
    return super.close();
  }
}
