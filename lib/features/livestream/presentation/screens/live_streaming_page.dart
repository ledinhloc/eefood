import 'dart:async';

import 'package:camera/camera.dart';
import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/helpers.dart';
import '../../data/model/live_stream_response.dart';
import '../provider/start_live_cubit.dart';

class LiveStreamScreen extends StatefulWidget {
  final LiveStreamResponse stream;
  final LocalVideoTrack? localVideoTrack;
  final LocalAudioTrack? localAudioTrack;

  const LiveStreamScreen({
    Key? key,
    required this.stream,
    this.localVideoTrack,
    this.localAudioTrack,
  }) : super(key: key);

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  Room? _room;
  bool _isMicOn = true;
  bool _isCameraOn = true;
  LocalVideoTrack? _localVideoTrack;
  LocalAudioTrack? _localAudioTrack;
  bool _isFrontCamera = true;
  bool _isFlashOn = false;
  CameraController? _cameraController;
  Timer? _timer; //thoi gian live
  final List<String> _comments = [];
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _localVideoTrack = widget.localVideoTrack;
    _localAudioTrack = widget.localAudioTrack;
    _connectToRoom();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {}); // Refresh UI để cập nhật thời gian
      }
    });
  }

  Future<void> _connectToRoom() async {
    try {
      _room = Room();
      _room!.addListener(_onRoomUpdate);

      // Connect to room
      await _room!.connect('ws://10.0.2.2:7880', widget.stream.livekitToken!);

      // Publish video - KIỂM TRA track != null VÀ chưa bị stopped
      if (widget.localVideoTrack != null &&
          widget.localVideoTrack!.mediaStreamTrack.enabled) {
        print('Publishing video track...');

        await _room!.localParticipant!.publishVideoTrack(
          widget.localVideoTrack!,
        );

        print('Video track published');
      }

      // Publish audio - TẠO MỚI track
      // print('Creating audio track...')

      if (widget.localAudioTrack != null &&
          widget.localAudioTrack!.mediaStreamTrack.enabled) {
        print('Publishing audio track...');

        await _room!.localParticipant!.publishAudioTrack(
          widget.localAudioTrack!,
        );

        print('Audio track published');
      }

      setState(() {});
    } catch (e) {
      print('Lỗi kết nối LiveKit: $e');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  void _onRoomUpdate() {
    setState(() {});
  }

  Duration _getElapsedTime() {
    if (widget.stream.startedAt != null) {
      return DateTime.now().difference(widget.stream.startedAt!);
    }
    return Duration.zero;
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
  Future<void> _toggleMic() async {
    if (_localAudioTrack == null) return;

    try {
      if (_isMicOn) {
        await _localAudioTrack!.disable();
        print('Microphone disabled');
      } else {
        await _localAudioTrack!.enable();
        print('Microphone enabled');
      }

      setState(() {
        _isMicOn = !_isMicOn;
      });
    } catch (e) {
      print('Error toggling microphone: $e');
    }
  }

  Future<void> _toggleCamera() async {
    if (_localVideoTrack == null) return;

    try {
      if (_isCameraOn) {
        await _localVideoTrack!.disable();
        print("camera disable");
      } else {
        await _localVideoTrack!.enable();
        print("camera enable");
      }
      setState(() {
        _isCameraOn = !_isCameraOn;
      });
    } catch (e) {
      print('Error toggling camera: $e');
    }
  }

  Future<void> _switchCamera() async {
    print("switch camera: ------${!_isFrontCamera ? "front" : "back"}");
    if (_localVideoTrack == null) {
      print('track is null');
      return;
    }

    try {
      // Tắt flash khi chuyển camera
      if (_isFlashOn && _cameraController != null) {
        await _cameraController!.setFlashMode(FlashMode.off);
        _isFlashOn = false;
      }

      final wasEnabled = _isCameraOn;
      final newPosition = _isFrontCamera
          ? CameraPosition.back
          : CameraPosition.front;

      await _localVideoTrack!.stop();
      _localVideoTrack = await LocalVideoTrack.createCameraTrack(
        CameraCaptureOptions(cameraPosition: newPosition),
      );

      if (_room?.localParticipant != null) {
        await _room!.localParticipant!.publishVideoTrack(_localVideoTrack!);
      }

      if (!wasEnabled) {
        await _localVideoTrack!.disable();
      }
      setState(() {
        _isFrontCamera = !_isFrontCamera;
      });
    } on Exception catch (e) {
      print('Error switch camera');
      try {
        _localVideoTrack = await LocalVideoTrack.createCameraTrack(
          CameraCaptureOptions(
            cameraPosition: _isFrontCamera
                ? CameraPosition.front
                : CameraPosition.back,
          ),
        );

        if (_room?.localParticipant != null) {
          await _room!.localParticipant!.publishVideoTrack(_localVideoTrack!);
        }

        setState(() {});
      } catch (e2) {
        print("Error recreating track: $e2");
      }
    }
  }

  Future<void> _endLiveStream() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kết thúc phát trực tiếp?'),
        content: const Text(
          'Bạn có chắc muốn kết thúc phiên phát trực tiếp này?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: (){
              Navigator.pop(context, true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Kết thúc'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _localVideoTrack?.stop();
      await _localAudioTrack?.stop();

      await _room?.disconnect().timeout(
        const Duration(seconds: 2),
        onTimeout: () => print("disconnect bị treo – bỏ qua để thoát UI"),
      );

      await _room?.dispose();
      if (!mounted) return;

      // context.read<StartLiveCubit>().endLive(widget.stream.id);
      await getIt<StartLiveCubit>().endLive(widget.stream.id);
      Navigator.pop(context, true);
      // Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _sendComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        _comments.add(_commentController.text);
      });
      _commentController.clear();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _room?.removeListener(_onRoomUpdate);
    _room?.disconnect();
    _room?.dispose();

    _localVideoTrack?.stop();
    _localAudioTrack?.stop();

    _cameraController?.dispose();

    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final participantCount =
        (_room?.remoteParticipants.length ?? 0) +
        (_room?.localParticipant != null ? 1 : 0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video display
          Positioned.fill(
            child: _localVideoTrack != null && _isCameraOn
                ? VideoTrackRenderer(_localVideoTrack!)
                : Container(
                    color: Colors.black,
                    child: const Center(
                      child: Icon(
                        Icons.videocam_off,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    // Live badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "TRỰC TIẾP",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatDuration(_getElapsedTime()), // THÊM
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    ),
                    const SizedBox(width: 8),
                    // Privacy
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lock, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Chỉ mình tôi',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Close button
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: _endLiveStream,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // User info
          Positioned(
            bottom: 120,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.stream.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$participantCount người đang xem',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Comments list
          Positioned(
            bottom: 80,
            left: 16,
            right: 100,
            height: 200,
            child: ListView.builder(
              reverse: true,
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[_comments.length - 1 - index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    comment,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),

          // Right side controls
          Positioned(
            right: 12,
            bottom: 120,
            child: Column(
              children: [
                _buildRoundButton(
                  icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                  onPressed: _toggleCamera,
                ),
                const SizedBox(height: 16),
                _buildRoundButton(
                  icon: Icons.cameraswitch,
                  onPressed: _switchCamera,
                ),
                const SizedBox(height: 16),
                _buildRoundButton(
                  icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
                  onPressed: _toggleFlash,
                ),
                const SizedBox(height: 16),
                _buildRoundButton(
                  icon: _isMicOn ? Icons.mic : Icons.mic_off,
                  onPressed: _toggleMic,
                ),
                // const SizedBox(height: 16),
                // _buildRoundButton(icon: Icons.face, onPressed: () {}),
                // const SizedBox(height: 16),
                // _buildRoundButton(icon: Icons.expand_more, onPressed: () {}),
              ],
            ),
          ),

          // Bottom bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Comment input
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextField(
                          controller: _commentController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Nhấn để thêm bình luận...',
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendComment(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Send button
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendComment,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom navigation
          // Positioned(
          //   left: 0,
          //   right: 0,
          //   bottom: 0,
          //   child: Container(
          //     color: Colors.black,
          //     child: SafeArea(
          //       top: false,
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //         children: [
          //           _buildNavButton(Icons.person_add_outlined),
          //           _buildNavButton(Icons.grid_view),
          //           _buildNavButton(Icons.search),
          //           _buildNavButton(Icons.menu),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildRoundButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        iconSize: 24,
      ),
    );
  }

  Widget _buildNavButton(IconData icon) {
    return IconButton(
      icon: Icon(icon, color: Colors.white),
      onPressed: () {},
    );
  }
}
