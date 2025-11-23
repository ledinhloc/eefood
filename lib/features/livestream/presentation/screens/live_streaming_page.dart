import 'package:eefood/core/constants/app_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../data/model/live_stream_response.dart';
import '../provider/start_live_cubit.dart';

class LiveStreamScreen extends StatefulWidget {
  final LiveStreamResponse stream;
  final LocalVideoTrack? localVideoTrack;

  const LiveStreamScreen({
    Key? key,
    required this.stream,
    this.localVideoTrack,
  }) : super(key: key);

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  Room? _room;
  LocalAudioTrack? _localAudioTrack;
  bool _isMicOn = true;
  bool _isCameraOn = true;
  final List<String> _comments = [];
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _connectToRoom();
  }

  Future<void> _connectToRoom() async {
    try {
      _room = Room();
      _room!.addListener(_onRoomUpdate);

      // Connect to room
      await _room!.connect(
        'ws://10.0.2.2:7880',
        widget.stream.livekitToken!,
      );

      // print('Room connected successfully');

      // await Future.delayed(const Duration(seconds: 1));
      // if (_room!.localParticipant == null) {
      //   throw Exception('Local participant not ready');
      // }

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
      print('Creating audio track...');

      _localAudioTrack = await LocalAudioTrack.create(
        AudioCaptureOptions(
          // Có thể thêm options nếu cần
        ),
      );

      print('Publishing audio track...');

      await _room!.localParticipant!.publishAudioTrack(
        _localAudioTrack!,
      );

      print('Audio track published');

      setState(() {});

    } catch (e) {
      print('Lỗi kết nối LiveKit: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }
  void _onRoomUpdate() {
    setState(() {});
  }

  Future<void> _toggleMic() async {
    if (_localAudioTrack != null) {
      final newState = !_isMicOn; // đảo trạng thái hiện tại
      await _localAudioTrack!.mute(stopOnMute: !newState);
      setState(() {
        _isMicOn = newState;
      });
    }
  }

  Future<void> _toggleCamera() async {
    if (widget.localVideoTrack != null) {
      final newStateCamera = !_isCameraOn;
      await widget.localVideoTrack!.mute(stopOnMute: !newStateCamera);
      setState(() {
        _isCameraOn = newStateCamera;
      });
    }
  }

  Future<void> _endLiveStream() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kết thúc phát trực tiếp?'),
        content: const Text('Bạn có chắc muốn kết thúc phiên phát trực tiếp này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Kết thúc'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _room?.disconnect();
      await _room?.dispose();
      await widget.localVideoTrack?.stop();
      await _localAudioTrack?.stop();

      if (mounted) {
        context.read<StartLiveCubit>().endLive(widget.stream.id);
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
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
    _room?.removeListener(_onRoomUpdate);
    _room?.disconnect();
    _room?.dispose();
    widget.localVideoTrack?.stop();
    _localAudioTrack?.stop();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final participantCount = (_room?.remoteParticipants.length ?? 0) + (_room?.localParticipant != null ? 1 : 0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video display
          Positioned.fill(
            child: widget.localVideoTrack != null && _isCameraOn
                ? VideoTrackRenderer(widget.localVideoTrack!)
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
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
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
                      child: const Text(
                        'TRỰC TIẾP',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
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
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
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
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
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
                  icon: Icons.flash_off,
                  onPressed: () {},
                ),
                const SizedBox(height: 16),
                _buildRoundButton(
                  icon: _isMicOn ? Icons.mic : Icons.mic_off,
                  onPressed: _toggleMic,
                ),
                const SizedBox(height: 16),
                _buildRoundButton(
                  icon: Icons.cameraswitch,
                  onPressed: () {},
                ),
                const SizedBox(height: 16),
                _buildRoundButton(
                  icon: Icons.face,
                  onPressed: () {},
                ),
                const SizedBox(height: 16),
                _buildRoundButton(
                  icon: Icons.expand_more,
                  onPressed: () {},
                ),
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
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.black,
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavButton(Icons.person_add_outlined),
                    _buildNavButton(Icons.grid_view),
                    _buildNavButton(Icons.search),
                    _buildNavButton(Icons.menu),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
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