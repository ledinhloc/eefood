// presentation/screens/live_viewer_screen.dart
import 'dart:async';
import 'package:eefood/features/livestream/presentation/widgets/stream_ended_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../../../core/utils/food_emotion_helper.dart';
import '../../data/model/live_reaction_response.dart';
import '../provider/live_comment_cubit.dart';
import '../provider/live_reaction_cubit.dart';
import '../provider/live_reaction_state.dart';
import '../provider/live_viewer_cubit.dart';
import '../provider/watch_live_cubit.dart';
import '../provider/watch_live_state.dart';
import '../widgets/live_comment_list.dart';
import '../widgets/live_reaction_animation.dart';
import '../widgets/live_status_timer.dart';
import '../widgets/viewer_list_bottom_sheet.dart';

class LiveViewerScreen extends StatefulWidget {
  final int streamId;

  const LiveViewerScreen({Key? key, required this.streamId}) : super(key: key);

  @override
  State<LiveViewerScreen> createState() => _LiveViewerScreenState();
}

class _LiveViewerScreenState extends State<LiveViewerScreen> {
  Timer? _timer;
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<LiveReactionResponse> _activeReactions = [];

  @override
  void initState() {
    super.initState();

    // Load stream
    context.read<WatchLiveCubit>().loadLive(widget.streamId);

    // Join as viewer
    context.read<LiveViewerCubit>().joinLiveStream();

    // Timer for UI updates
    // _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    //   if (mounted) setState(() {});
    // });
  }

  void _handleStreamEnded(String? message) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StreamEndedDialog(
          message: message,
            onClose: () {
              Navigator.pop(context);//dong diaglog
              Navigator.pop(context); // thoat man hinh
            },);
      }
    );
  }

  Future<void> _sendReaction(FoodEmotion emotion) async {
    try {
      await context.read<LiveReactionCubit>().createReaction(

        emotion,
      );
    } catch (e) {
      print('Error sending reaction: $e');
    }
  }

  void _onReactionCompleted(LiveReactionResponse reaction) {
    setState(() {
      _activeReactions.remove(reaction);
    });
  }

  void _leaveLiveStream() async {
    context.read<LiveViewerCubit>().leaveLiveStream();
    await context.read<WatchLiveCubit>().disconnect();
    if (mounted) Navigator.pop(context);
  }

  void _showViewerList() {
    final viewerCubit = context.read<LiveViewerCubit>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return BlocProvider.value(
          value: viewerCubit,
          child: const ViewerListBottomSheet(),
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
        BlocListener<LiveReactionCubit, LiveReactionState>(
          listener: (context, reactionState) {
            if (reactionState.reactions.isNotEmpty) {
              final newReactions = reactionState.reactions
                  .where((r) => !_activeReactions.contains(r))
                  .toList();

              if (newReactions.isNotEmpty) {
                setState(() {
                  _activeReactions.addAll(newReactions);
                });
              }
            }
          },
        ),
        BlocListener<WatchLiveCubit, WatchLiveState>(
          listenWhen: (previous, current) =>
          previous.isStreamEnded != current.isStreamEnded,
          listener: (context, state) {
            if (state.isStreamEnded) {
              _handleStreamEnded(state.streamEndMessage);
            }
          },
        ),
      ],
      child: BlocBuilder<WatchLiveCubit, WatchLiveState>(
        builder: (context, state) {
          if (state.loading) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          if (state.error != null) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi: ${state.error}',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<WatchLiveCubit>().loadLive(widget.streamId);
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.stream == null) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Text(
                  'Không tìm thấy phiên phát sóng',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }

          final stream = state.stream!;
          final participantCount = (state.room?.remoteParticipants.length ?? 0) + 1;

          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                // Video display
                Positioned.fill(
                  child: state.remoteVideoTrack != null
                      ? VideoTrackRenderer(state.remoteVideoTrack!)
                      : Container(
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            state.isConnecting ? Icons.sync : Icons.videocam_off,
                            color: Colors.white54,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.isConnecting
                                ? 'Đang kết nối...'
                                : state.isConnected
                                ? 'Đang chờ video...'
                                : 'Chưa kết nối',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                          if (state.isConnecting)
                            const Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: CircularProgressIndicator(
                                color: Colors.white54,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Reactions
                ..._activeReactions.map((reaction) {
                  return LiveReactionAnimation(
                    key: ValueKey(reaction.id),
                    reaction: reaction,
                    onComplete: () => _onReactionCompleted(reaction),
                  );
                }),

                // Top bar
                _buildTopBar(stream, participantCount),

                // Streamer info
                _buildStreamerInfo(stream),

                // Comments
                Positioned(
                  bottom: 30,
                  left: 10,
                  right: 16,
                  height: 400,
                  child: LiveCommentList(
                    controller: _commentController,
                    scrollController: _scrollController,
                  ),
                ),

                // Reaction buttons
                _buildReactionButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(stream, int participantCount) {
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
              LiveStatusTimer(startTime: stream.startedAt!),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _showViewerList,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.visibility, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '$participantCount',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: _leaveLiveStream,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreamerInfo(stream) {
    return Positioned(
      top: 110,
      left: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              backgroundImage:
              stream.avatarUrl != null ? NetworkImage(stream.avatarUrl!) : null,
              child: stream.avatarUrl == null
                  ? const Icon(Icons.person, color: Colors.white, size: 20)
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              stream.username ?? 'Streamer',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionButtons() {
    return Positioned(
      right: 12,
      bottom: 200,
      child: Column(
        children: FoodEmotion.values.map((emotion) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => _sendReaction(emotion),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: FoodEmotionHelper.getColor(emotion).withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: FoodEmotionHelper.getColor(emotion).withOpacity(0.6),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    FoodEmotionHelper.getEmoji(emotion),
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}