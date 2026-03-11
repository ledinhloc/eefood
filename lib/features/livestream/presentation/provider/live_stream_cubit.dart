// presentation/provider/live_stream_cubit.dart
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart';
import 'live_stream_state.dart';

class LiveStreamCubit extends Cubit<LiveStreamState> {
  CameraController? _cameraController;

  LiveStreamCubit() : super(LiveStreamState.initial());

  void _safeEmit(LiveStreamState newState) {
    if (!isClosed) emit(newState);
  }

  /// Set tracks (dùng trong LivePrepScreen)
  void setTracks(LocalVideoTrack videoTrack, LocalAudioTrack audioTrack) {
    _safeEmit(state.copyWith(
      localVideoTrack: videoTrack,
      localAudioTrack: audioTrack,
      isCameraOn: true,
      isMicOn: true,
      clearError: true,
    ));
  }

  /// Connect to LiveKit room
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
        await room.localParticipant!
            .publishVideoTrack(state.localVideoTrack!);
      }

      if (state.localAudioTrack!.mediaStreamTrack.enabled) {
        await room.localParticipant!
            .publishAudioTrack(state.localAudioTrack!);
      }

      _safeEmit(state.copyWith(
        room: room,
        isConnected: true,
        clearError: true,
      ));
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

      _safeEmit(state.copyWith(isCameraOn: !state.isCameraOn));
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

      _safeEmit(state.copyWith(isMicOn: !state.isMicOn));
    } catch (e) {
      _safeEmit(state.copyWith(error: 'Error toggling mic: $e'));
    }
  }

  Future<void> switchCamera() async {
    if (state.localVideoTrack == null) return;

    try {
      if (state.isFlashOn && _cameraController != null) {
        await _cameraController!.setFlashMode(FlashMode.off);
        _safeEmit(state.copyWith(isFlashOn: false));
      }

      final wasEnabled = state.isCameraOn;
      final newPosition =
      state.isFrontCamera ? CameraPosition.back : CameraPosition.front;

      await state.localVideoTrack!.stop();
      await state.localVideoTrack!.dispose();

      final newTrack = await LocalVideoTrack.createCameraTrack(
        CameraCaptureOptions(cameraPosition: newPosition),
      );

      if (state.room?.localParticipant != null) {
        await state.room!.localParticipant!.publishVideoTrack(newTrack);
      }

      if (!wasEnabled) {
        await newTrack.disable();
      }

      _safeEmit(state.copyWith(
        localVideoTrack: newTrack,
        isFrontCamera: !state.isFrontCamera,
      ));
    } catch (e) {
      _safeEmit(state.copyWith(error: 'Error switching camera: $e'));
    }
  }

  Future<void> toggleFlash() async {
    if (state.localVideoTrack == null) return;

    if (state.isFrontCamera) {
      _safeEmit(state.copyWith(error: 'Flash chỉ hoạt động với camera sau'));
      return;
    }

    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
      );

      if (_cameraController == null ||
          !_cameraController!.value.isInitialized) {
        _cameraController =
            CameraController(backCamera, ResolutionPreset.high);
        await _cameraController!.initialize();
      }

      await _cameraController!.setFlashMode(
        state.isFlashOn ? FlashMode.off : FlashMode.torch,
      );

      _safeEmit(state.copyWith(isFlashOn: !state.isFlashOn));
    } catch (e) {
      _safeEmit(state.copyWith(error: 'Error toggling flash: $e'));
    }
  }

  /// Dispose chỉ tracks (không disconnect room)
  Future<void> disposeTracksOnly() async {
    await state.localVideoTrack?.stop();
    await state.localVideoTrack?.dispose();
    await state.localAudioTrack?.stop();
    await state.localAudioTrack?.dispose();
    await _cameraController?.dispose();
    _cameraController = null;

    _safeEmit(state.copyWith(
      clearVideoTrack: true,
      clearAudioTrack: true,
      isConnected: false,
      isCameraOn: true,
      isMicOn: true,
      isFrontCamera: true,
      isFlashOn: false,
      viewerCount: 0,
      clearError: true,
    ));
  }

  /// Disconnect and cleanup
  Future<void> disconnect() async {
    state.room?.removeListener(_onRoomUpdate);
    await state.localVideoTrack?.stop();
    await state.localVideoTrack?.dispose();
    await state.localAudioTrack?.stop();
    await state.localAudioTrack?.dispose();
    await state.room?.disconnect();
    await state.room?.dispose();
    await _cameraController?.dispose();
    _cameraController = null;

    _safeEmit(state.copyWith(
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
    ));
  }

  @override
  Future<void> close() async {
    state.room?.removeListener(_onRoomUpdate);
    await disconnect();
    return super.close();
  }
}