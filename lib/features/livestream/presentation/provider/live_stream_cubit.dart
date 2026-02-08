// presentation/provider/live_stream_cubit.dart
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart';
import 'live_stream_state.dart';

class LiveStreamCubit extends Cubit<LiveStreamState> {
  CameraController? _cameraController;

  LiveStreamCubit() : super(LiveStreamState.initial());

  /// Connect to LiveKit room
  Future<void> connectToRoom(
      String livekitUrl,
      String token,
      LocalVideoTrack videoTrack,
      LocalAudioTrack audioTrack,
      ) async {
    try {
      final room = Room();
      room.addListener(_onRoomUpdate);

      await room.connect(livekitUrl, token);

      if (videoTrack.mediaStreamTrack.enabled) {
        await room.localParticipant!.publishVideoTrack(videoTrack);
      }

      if (audioTrack.mediaStreamTrack.enabled) {
        await room.localParticipant!.publishAudioTrack(audioTrack);
      }

      emit(state.copyWith(
        room: room,
        localVideoTrack: videoTrack,
        localAudioTrack: audioTrack,
        isConnected: true,
      ));
    } catch (e) {
      emit(state.copyWith(error: 'Connection error: $e'));
    }
  }

  void _onRoomUpdate() {
    final participantCount = (state.room?.remoteParticipants.length ?? 0) + 1;
    emit(state.copyWith(viewerCount: participantCount));
  }

  /// Toggle camera on/off
  Future<void> toggleCamera() async {
    if (state.localVideoTrack == null) return;

    try {
      if (state.isCameraOn) {
        await state.localVideoTrack!.disable();
      } else {
        await state.localVideoTrack!.enable();
      }

      emit(state.copyWith(isCameraOn: !state.isCameraOn));
    } catch (e) {
      emit(state.copyWith(error: 'Error toggling camera: $e'));
    }
  }

  /// Toggle microphone on/off
  Future<void> toggleMic() async {
    if (state.localAudioTrack == null) return;

    try {
      if (state.isMicOn) {
        await state.localAudioTrack!.disable();
      } else {
        await state.localAudioTrack!.enable();
      }

      emit(state.copyWith(isMicOn: !state.isMicOn));
    } catch (e) {
      emit(state.copyWith(error: 'Error toggling mic: $e'));
    }
  }

  /// Switch between front/back camera
  Future<void> switchCamera() async {
    if (state.localVideoTrack == null) return;

    try {
      // Tắt flash khi chuyển camera
      if (state.isFlashOn && _cameraController != null) {
        await _cameraController!.setFlashMode(FlashMode.off);
        emit(state.copyWith(isFlashOn: false));
      }

      final wasEnabled = state.isCameraOn;
      final newPosition = state.isFrontCamera
          ? CameraPosition.back
          : CameraPosition.front;

      await state.localVideoTrack!.stop();

      final newTrack = await LocalVideoTrack.createCameraTrack(
        CameraCaptureOptions(cameraPosition: newPosition),
      );

      if (state.room?.localParticipant != null) {
        await state.room!.localParticipant!.publishVideoTrack(newTrack);
      }

      if (!wasEnabled) {
        await newTrack.disable();
      }

      emit(state.copyWith(
        localVideoTrack: newTrack,
        isFrontCamera: !state.isFrontCamera,
      ));
    } catch (e) {
      emit(state.copyWith(error: 'Error switching camera: $e'));
    }
  }

  /// Toggle flash (back camera only)
  Future<void> toggleFlash() async {
    if (state.localVideoTrack == null) return;

    if (state.isFrontCamera) {
      emit(state.copyWith(error: 'Flash only works with back camera'));
      return;
    }

    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
      );

      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        _cameraController = CameraController(backCamera, ResolutionPreset.high);
        await _cameraController!.initialize();
      }

      await _cameraController!.setFlashMode(
        state.isFlashOn ? FlashMode.off : FlashMode.torch,
      );

      emit(state.copyWith(isFlashOn: !state.isFlashOn));
    } catch (e) {
      emit(state.copyWith(error: 'Error toggling flash: $e'));
    }
  }

  /// Disconnect and cleanup
  Future<void> disconnect() async {
    await state.localVideoTrack?.stop();
    await state.localAudioTrack?.stop();
    await state.room?.disconnect();
    await state.room?.dispose();
    await _cameraController?.dispose();
  }

  @override
  Future<void> close() {
    disconnect();
    return super.close();
  }
}