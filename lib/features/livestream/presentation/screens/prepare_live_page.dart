import 'dart:io';

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
  bool _isCameraOn = true;
  bool _isMicOn = true;
  bool _isFrontCamera = true;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    try {
      _localVideoTrack = await LocalVideoTrack.createCameraTrack(
        const CameraCaptureOptions(cameraPosition: CameraPosition.front),
      );
      setState(() {});
    } catch (e) {
      print('Lỗi khởi tạo camera: $e');
      showCustomSnackBar(context, "Không thể mở camera");
    }
  }

  Future<void> _toggleCamera() async {
    if (_localVideoTrack != null) {
      if (_isCameraOn) {
        await _localVideoTrack!.mute();
      } else {
        await _localVideoTrack!.unmute();
      }
      setState(() {
        _isCameraOn = !_isCameraOn;
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_localVideoTrack != null) {
      await _localVideoTrack!.setCameraPosition(
        _isFrontCamera ? CameraPosition.back : CameraPosition.front,
      );
      setState(() {
        _isFrontCamera = !_isFrontCamera;
      });
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

    context.read<StartLiveCubit>().startLive(_descriptionController.text);
  }

  @override
  void dispose() {
    // _localVideoTrack?.stop();
    // _localVideoTrack?.dispose();
    _descriptionController.dispose();
    super.dispose();
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
                          onPressed: () => Navigator.pop(context),
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
                        label: 'Flash đang tắt',
                        onPressed: _toggleCamera,
                      ),
                      const SizedBox(height: 20),
                      _buildControlButton(
                        icon: _isMicOn ? Icons.mic : Icons.mic_off,
                        label: 'Tắt tiếng micro',
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
                      const SizedBox(height: 20),
                      _buildControlButton(
                        icon: Icons.face,
                        label: 'Nhãn dán',
                        onPressed: () {},
                      ),
                      const SizedBox(height: 20),
                      _buildControlButton(
                        icon: Icons.star,
                        label: 'Tăng tính năng cá thiên',
                        onPressed: () {},
                      ),
                      const SizedBox(height: 20),
                      _buildControlButton(
                        icon: Icons.text_fields,
                        label: 'Văn bản',
                        onPressed: () {},
                      ),
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