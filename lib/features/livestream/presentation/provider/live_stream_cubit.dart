// presentation/provider/live_stream_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart';

import 'live_stream_state.dart';

class LiveStreamCubit extends Cubit<LiveStreamState> {
  LiveStreamCubit() : super(LiveStreamState.initial());

  void _safeEmit(LiveStreamState newState) {
    if (!isClosed) emit(newState);
  }

  void setTracks(LocalVideoTrack videoTrack, LocalAudioTrack audioTrack) {
    _safeEmit(
      state.copyWith(
        localVideoTrack: videoTrack,
        localAudioTrack: audioTrack,
        isCameraOn: true,
        isMicOn: true,
        clearError: true,
      ),
    );
  }

  Future<void> connectToRoom(String livekitUrl, String token) async {
    if (state.isConnected && state.room != null) {
      return;
    }

    if (state.localVideoTrack == null || state.localAudioTrack == null) {
      _safeEmit(state.copyWith(error: 'Tracks not initialized'));
      return;
    }

    try {
      final room = Room();
      room.addListener(_onRoomUpdate);

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
    } catch (e) {
      _safeEmit(state.copyWith(error: 'Connection error: $e'));
    }
  }

  void _onRoomUpdate() {
    if (isClosed) return;
    final participantCount = (state.room?.remoteParticipants.length ?? 0) + 1;
    _safeEmit(state.copyWith(viewerCount: participantCount));
  }

  Future<void> toggleCamera() async {
    if (state.localVideoTrack == null) return;

    try {
      if (state.isCameraOn) {
        await state.localVideoTrack!.disable();
      } else {
        await state.localVideoTrack!.enable();
      }

      _safeEmit(
        state.copyWith(isCameraOn: !state.isCameraOn, clearError: true),
      );
    } catch (e) {
      _safeEmit(state.copyWith(error: 'Error toggling camera: $e'));
    }
  }

  Future<void> toggleMic() async {
    if (state.localAudioTrack == null) return;

    try {
      if (state.isMicOn) {
        await state.localAudioTrack!.disable();
      } else {
        await state.localAudioTrack!.enable();
      }

      _safeEmit(state.copyWith(isMicOn: !state.isMicOn, clearError: true));
    } catch (e) {
      _safeEmit(state.copyWith(error: 'Error toggling mic: $e'));
    }
  }

  Future<void> switchCamera() async {
    if (state.localVideoTrack == null) return;

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
        viewerCount: 0,
        clearError: true,
      ),
    );
  }

  Future<void> disconnect() async {
    state.room?.removeListener(_onRoomUpdate);
    await state.localVideoTrack?.stop();
    await state.localVideoTrack?.dispose();
    await state.localAudioTrack?.stop();
    await state.localAudioTrack?.dispose();
    await state.room?.disconnect();
    await state.room?.dispose();

    _safeEmit(
      state.copyWith(
        clearRoom: true,
        clearVideoTrack: true,
        clearAudioTrack: true,
        isConnected: false,
        viewerCount: 0,
        isCameraOn: true,
        isMicOn: true,
        isFrontCamera: true,
        isFlashOn: false,
        clearError: true,
      ),
    );
  }

  @override
  Future<void> close() async {
    state.room?.removeListener(_onRoomUpdate);
    await disconnect();
    return super.close();
  }
}
