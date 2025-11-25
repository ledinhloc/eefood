import 'dart:io';

import 'package:camera/camera.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart';

import '../provider/start_live_cubit.dart';
import 'live_streaming_page.dart';

class LivePrepScreen extends StatefulWidget {
  const LivePrepScreen({Key? key}) : super(key: key);

  @override
  State<LivePrepScreen> createState() => _LivePrepScreenState();
}

class _LivePrepScreenState extends State<LivePrepScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  LocalVideoTrack? _localVideoTrack;
  LocalAudioTrack? _localAudioTrack;
  bool _isCameraOn = true;
  bool _isMicOn = true;
  bool _isFrontCamera = true;
  bool _isFlashOn = false;
  CameraController? _cameraController;
  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeMicrophone();
  }

  Future<void> _initializeMicrophone() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    try {
      // print(' Initializing microphone...');

      _localAudioTrack = await LocalAudioTrack.create(
        AudioCaptureOptions(
          noiseSuppression: true,
          echoCancellation: true,
          autoGainControl: true,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 200));

      if (mounted) {
        setState(() {});
      }

      // print(' Microphone initialized');
    } catch (e) {
      print('Lỗi khởi tạo microphone: $e');
      if (mounted) {
        showCustomSnackBar(context, "Không thể mở microphone");
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (_localVideoTrack == null) return;

    // Flash chỉ hoạt động với camera sau
    if (_isFrontCamera) {
      showCustomSnackBar(context, "Flash chỉ hoạt động với camera sau");
      return;
    }

    try {
      _isFlashOn = !_isFlashOn;

      // Lấy danh sách camera
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
      );

      // Khởi tạo CameraController nếu chưa có
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        _cameraController = CameraController(
          backCamera,
          ResolutionPreset.high,
        );
        await _cameraController!.initialize();
      }

      // Bật/tắt flash
      await _cameraController!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );

      setState(() {});

      print('Flash ${_isFlashOn ? "ON" : "OFF"}');
    } catch (e) {
      print('Error toggling flash: $e');
      _isFlashOn = !_isFlashOn; // Revert lại trạng thái
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi bật/tắt flash: $e')),
      );
    }
  }

  Future<void> _initializeCamera() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    try {
      _localVideoTrack = await LocalVideoTrack.createCameraTrack(
        const CameraCaptureOptions(cameraPosition: CameraPosition.front),
      );
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Lỗi khởi tạo camera: $e');
      showCustomSnackBar(context, "Không thể mở camera");
    }
  }

  //  THÊM hàm này
  Future<void> _toggleMicrophone() async {
    if (_localAudioTrack == null) {
      print('---- Audio track is null');
      return;
    }

    try {
      if (_isMicOn) {
        await _localAudioTrack!.disable();
        print(' Microphone disabled');
      } else {
        await _localAudioTrack!.enable();
        print(' Microphone enabled');
      }

      if (mounted) {
        setState(() {
          _isMicOn = !_isMicOn;
        });
      }
    } catch (e) {
      print('Error toggling microphone: $e');
      if (mounted) {
        showCustomSnackBar(
            context,
            'Không thể ${_isMicOn ? "tắt" : "bật"} microphone'
        );
      }
    }
  }

  Future<void> _toggleCamera() async {
    if (_localVideoTrack == null) return;
    try {
      if (_localVideoTrack != null) {
        if (_isCameraOn) {
          await _localVideoTrack!.disable();
          print("camera disable");
          // await _localVideoTrack!.mute();
        } else {
          await _localVideoTrack!.enable();
          print("camera enable");
        }
        setState(() {
          _isCameraOn = !_isCameraOn;
        });
      }
    } on Exception catch (e) {
      print('Error toggling camera: $e');
      if (mounted) {
        showCustomSnackBar(
            context,
            'Không thể ${_isCameraOn ? "tắt" : "bật"} camera: $e'
        );
      }
    }
  }

  Future<void> _switchCamera() async {
    print("switch camera: ---${!_isFrontCamera?'front':'back'}");
    if(_localVideoTrack == null){
      print('track is null');
      return;
    }
    
    try {
      if (_isFlashOn && _cameraController != null) {
        await _cameraController!.setFlashMode(FlashMode.off);
        _isFlashOn = false;
      }

      final wasEnabled = _isCameraOn;
      final newPosition = _isFrontCamera ? CameraPosition.back : CameraPosition.front;

      // Stop track cũ
      await _localVideoTrack!.stop();
      // Tạo track mới
      _localVideoTrack = await LocalVideoTrack.createCameraTrack(
        CameraCaptureOptions(
          cameraPosition: newPosition,
        ),
      );

      // Khôi phục state
      if (!wasEnabled) {
        await _localVideoTrack!.disable();
      }
      setState(() {
        _isFrontCamera = !_isFrontCamera;
      });
    } on Exception catch (e) {
      print("Error switching camera: $e");
      // Tạo lại track cũ nếu fail
      _localVideoTrack = await LocalVideoTrack.createCameraTrack(
        CameraCaptureOptions(
          cameraPosition: _isFrontCamera ? CameraPosition.front : CameraPosition.back,
        ),
      );
      setState(() {});
    }
  }

  void _startLiveStream() {
    // if (_descriptionController.text.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Vui lòng nhập mô tả')),
    //   );
    //   return;
    // }
    if(_localVideoTrack == null){
      showCustomSnackBar(context, 'Camera chua san sang');
      return;
    }
    if (_localAudioTrack == null) {
      showCustomSnackBar(context, 'Microphone chưa sẵn sàng');
      return;
    }
    context.read<StartLiveCubit>().startLive(_descriptionController.text);
  }

  @override
  void dispose() {
    // _localVideoTrack?.stop();
    // _localVideoTrack?.dispose();
    _cameraController?.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _disposeCameraAndAudio() async {
    _cameraController?.dispose();
    try {
      if (_localVideoTrack != null) {
        await _localVideoTrack!.stop();
        _localVideoTrack!.dispose();
        _localVideoTrack = null;
      }
      if (_localAudioTrack != null) {
        await _localAudioTrack!.stop();
        _localAudioTrack!.dispose();
        _localAudioTrack = null;
      }

    } catch (e) {
      print('Error disposing camera, audio: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<StartLiveCubit, StartLiveState>(
        listener: (context, state) {
          if (state.stream != null) {
            // Chuyển sang màn hình live
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => LiveStreamScreen(
                  stream: state.stream!,
                  localVideoTrack: _localVideoTrack,
                  localAudioTrack: _localAudioTrack,
                ),
              ),
            );
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Preview camera
              if (_localVideoTrack != null && _isCameraOn)
                Positioned.fill(
                  child: VideoTrackRenderer(_localVideoTrack!),
                )
              else
                Container(
                  color: Colors.black,
                  child: const Center(
                    child: Icon(
                      Icons.videocam_off,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),

              // Top bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () async {
                            await _disposeCameraAndAudio();
                            if (mounted) Navigator.pop(context);
                          },
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.lock, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Chỉ mình tôi',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.help_outline, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Control buttons (right side)
              Positioned(
                right: 16,
                top: 0,
                bottom: 200,
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlButton(
                        icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                        label: 'Camera',
                        onPressed: _toggleCamera,
                      ),
                      const SizedBox(height: 20),
                      _buildControlButton(
                        icon: _isMicOn ? Icons.mic : Icons.mic_off,
                        label: _isMicOn ? 'Tắt micro' : 'Bật micro',
                        onPressed: () {
                          setState(() {
                            _isMicOn = !_isMicOn;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildControlButton(
                        icon: Icons.cameraswitch,
                        label: 'Xoay',
                        onPressed: _switchCamera,
                      ),
                      _buildControlButton(
                        icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
                        label: 'Flash',
                        onPressed: _toggleCamera,
                      ),
                      const SizedBox(height: 20),
                      // const SizedBox(height: 20),
                      // _buildControlButton(
                      //   icon: Icons.face,
                      //   label: 'Nhãn dán',
                      //   onPressed: () {},
                      // ),
                      // const SizedBox(height: 20),
                      // _buildControlButton(
                      //   icon: Icons.star,
                      //   label: 'Tăng tính năng cá thiên',
                      //   onPressed: () {},
                      // ),
                      // const SizedBox(height: 20),
                      // _buildControlButton(
                      //   icon: Icons.text_fields,
                      //   label: 'Văn bản',
                      //   onPressed: () {},
                      // ),
                    ],
                  ),
                ),
              ),

              // Bottom section
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Description input
                      TextField(
                        controller: _descriptionController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Thêm mô tả...',
                          hintStyle: const TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                          prefixIcon: const Icon(
                            Icons.share,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            child: Icon(Icons.person),
                          ),
                          const SizedBox(width: 8),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chia sẻ lên',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Tin: Bật',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Start button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: state.loading ? null : _startLiveStream,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: state.loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            'Phát trực tiếp',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: onPressed,
            iconSize: 28,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}