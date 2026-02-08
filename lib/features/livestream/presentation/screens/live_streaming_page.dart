// presentation/screens/live_stream_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_keys.dart';
import '../../../../core/di/injection.dart';
import '../../data/model/live_reaction_response.dart';
import '../../data/model/live_stream_response.dart';
import '../provider/live_reaction_cubit.dart';
import '../provider/live_reaction_state.dart';
import '../provider/live_stream_cubit.dart';
import '../provider/live_stream_state.dart';
import '../provider/start_live_cubit.dart';
import '../widgets/live_comment_list.dart';
import '../widgets/live_reaction_animation.dart';
import '../widgets/live_status_timer.dart';
import 'package:livekit_client/livekit_client.dart';

class LiveStreamScreen extends StatefulWidget {
  final LiveStreamResponse stream;
  final LocalVideoTrack localVideoTrack;
  final LocalAudioTrack localAudioTrack;

  const LiveStreamScreen({
    Key? key,
    required this.stream,
    required this.localVideoTrack,
    required this.localAudioTrack,
  }) : super(key: key);

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  Timer? _timer;
  final TextEditingController _commentController = TextEditingController();
  final List<LiveReactionResponse> _activeReactions = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Connect to room qua Cubit
    context.read<LiveStreamCubit>().connectToRoom(
      AppKeys.livekitUrl,
      widget.stream.livekitToken!,
      widget.localVideoTrack,
      widget.localAudioTrack,
    );

    // Timer cho UI refresh (LiveStatusTimer)
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _onReactionCompleted(LiveReactionResponse reaction) {
    setState(() {
      _activeReactions.remove(reaction);
    });
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
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Kết thúc'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // Disconnect qua Cubit
      await context.read<LiveStreamCubit>().disconnect();

      if (!mounted) return;

      // End livestream qua API
      await getIt<StartLiveCubit>().endLive(widget.stream.id);

      if (!mounted) return;

      Navigator.pop(context, true);
    }
  }

  void _showViewerList() {
    final state = context.read<LiveStreamCubit>().state;
    final viewers = state.room?.remoteParticipants.values.toList() ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SizedBox(
          height: 350,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  "Người đang xem",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: viewers.isEmpty
                    ? const Center(
                  child: Text(
                    'Chưa có người xem',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
                    : ListView.builder(
                  itemCount: viewers.length,
                  itemBuilder: (context, index) {
                    final p = viewers[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        p.identity ?? "User",
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Reaction listener
        BlocListener<LiveReactionCubit, LiveReactionState>(
          listener: (context, reactionState) {
            if (reactionState.reactions.isNotEmpty) {
              final newReactions = reactionState.reactions
                  .where((r) => !_activeReactions.any((a) => a.id == r.id))
                  .toList();

              if (newReactions.isNotEmpty) {
                setState(() {
                  _activeReactions.addAll(newReactions);
                });
              }
            }
          },
        ),

        // LiveStream error listener
        BlocListener<LiveStreamCubit, LiveStreamState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error!)),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<LiveStreamCubit, LiveStreamState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                // Video display
                Positioned.fill(
                  child: state.localVideoTrack != null && state.isCameraOn
                      ? VideoTrackRenderer(state.localVideoTrack!)
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

                // Reactions overlay
                ..._activeReactions.map((reaction) {
                  return LiveReactionAnimation(
                    key: ValueKey(reaction.id),
                    reaction: reaction,
                    onComplete: () => _onReactionCompleted(reaction),
                  );
                }),

                // Top bar
                _buildTopBar(state.viewerCount),

                // Comments list
                Positioned(
                  bottom: 30,
                  left: 10,
                  right: 16,
                  height: 400,
                  child: LiveCommentList(
                    controller: _commentController,
                    scrollController: _scrollController,
                    isStreamer: true,
                  ),
                ),

                // Right controls
                _buildRightControls(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserInfo(int participantCount) {
    return GestureDetector(
      onTap: _showViewerList,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.remove_red_eye, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              '$participantCount',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(int participantCount) {
    return Positioned(
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
              LiveStatusTimer(startTime: widget.stream.startedAt!),
              const SizedBox(width: 8),
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
              const SizedBox(width: 8),
              _buildUserInfo(participantCount),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: _endLiveStream,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightControls(BuildContext context, LiveStreamState state) {
    return Positioned(
      right: 12,
      bottom: 120,
      child: Column(
        children: [
          _buildRoundButton(
            icon: state.isCameraOn ? Icons.videocam : Icons.videocam_off,
            onPressed: () => context.read<LiveStreamCubit>().toggleCamera(),
          ),
          const SizedBox(height: 16),
          _buildRoundButton(
            icon: Icons.cameraswitch,
            onPressed: () => context.read<LiveStreamCubit>().switchCamera(),
          ),
          const SizedBox(height: 16),
          _buildRoundButton(
            icon: state.isFlashOn ? Icons.flash_on : Icons.flash_off,
            onPressed: () => context.read<LiveStreamCubit>().toggleFlash(),
          ),
          const SizedBox(height: 16),
          _buildRoundButton(
            icon: state.isMicOn ? Icons.mic : Icons.mic_off,
            onPressed: () => context.read<LiveStreamCubit>().toggleMic(),
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
      decoration: const BoxDecoration(
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
}