import 'dart:async';

import 'package:eefood/core/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../../../core/di/injection.dart';
import '../../data/model/live_stream_response.dart';
import '../provider/watch_live_cubit.dart';

class LiveViewerScreen extends StatefulWidget {
  final int streamId;

  const LiveViewerScreen({
    Key? key,
    required this.streamId,
  }) : super(key: key);

  @override
  State<LiveViewerScreen> createState() => _LiveViewerScreenState();
}

class _LiveViewerScreenState extends State<LiveViewerScreen> {
  Room? _room;
  RemoteVideoTrack? _remoteVideoTrack;
  RemoteAudioTrack? _remoteAudioTrack;
  bool _isConnected = false;
  Timer? _timer;
  final List<CommentItem> _comments = [];
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Reactions
  final List<ReactionAnimation> _reactions = [];
  Timer? _reactionTimer;

  @override
  void initState() {
    super.initState();
    _loadStream();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {}); // Refresh UI để cập nhật thời gian và viewer count
      }
    });

    // Timer để xóa reactions cũ
    _reactionTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          _reactions.removeWhere((r) => r.isExpired());
        });
      }
    });
  }

  Future<void> _loadStream() async {
    await context.read<WatchLiveCubit>().loadLive(widget.streamId);
  }

  Future<void> _connectToRoom(LiveStreamResponse stream) async {
    if (_isConnected) return;

    try {
      _room = Room();
      _room!.addListener(_onRoomUpdate);

      // Connect to room
      await _room!.connect('ws://10.0.2.2:7880', stream.livekitToken!);

      // Listen for remote tracks
      _room!.remoteParticipants.values.forEach(_handleRemoteParticipant);

      setState(() {
        _isConnected = true;
      });

      print('Connected to room as viewer');
    } catch (e) {
      print('Lỗi kết nối LiveKit: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi kết nối: $e')),
        );
      }
    }
  }

  void _handleRemoteParticipant(RemoteParticipant participant) {
    participant.addListener(() {
      _onParticipantChanged(participant);
    });

    // Check existing tracks
    for (var track in participant.videoTrackPublications) {
      if (track.track != null && track.subscribed) {
        _remoteVideoTrack = track.track as RemoteVideoTrack;
        setState(() {});
      }
    }

    for (var track in participant.audioTrackPublications) {
      if (track.track != null && track.subscribed) {
        _remoteAudioTrack = track.track as RemoteAudioTrack;
        setState(() {});
      }
    }
  }

  void _onParticipantChanged(RemoteParticipant participant) {
    // Update video tracks
    for (var track in participant.videoTrackPublications) {
      if (track.track != null && track.subscribed) {
        _remoteVideoTrack = track.track as RemoteVideoTrack;
      }
    }

    // Update audio tracks
    for (var track in participant.audioTrackPublications) {
      if (track.track != null && track.subscribed) {
        _remoteAudioTrack = track.track as RemoteAudioTrack;
      }
    }

    setState(() {});
  }

  void _onRoomUpdate() {
    setState(() {});
  }

  Duration _getElapsedTime(LiveStreamResponse stream) {
    if (stream.startedAt != null) {
      return DateTime.now().difference(stream.startedAt!);
    }
    return Duration.zero;
  }

  void _sendComment() {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _comments.add(CommentItem(
        username: "Bạn", // Thay bằng username thật từ user data
        comment: _commentController.text.trim(),
        timestamp: DateTime.now(),
      ));
    });

    _commentController.clear();

    // Auto scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addReaction(String emoji) {
    setState(() {
      _reactions.add(ReactionAnimation(emoji: emoji));
    });
  }

  void _leaveLiveStream() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rời khỏi phát trực tiếp?'),
        content: const Text('Bạn có chắc muốn rời khỏi phiên phát trực tiếp này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Rời khỏi'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _room?.disconnect();
      await _room?.dispose();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _reactionTimer?.cancel();
    _room?.removeListener(_onRoomUpdate);
    _room?.disconnect();
    _room?.dispose();
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchLiveCubit, WatchLiveState>(
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
                    onPressed: _loadStream,
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

        // Connect to room if not connected
        if (!_isConnected && stream.livekitToken != null) {
          _connectToRoom(stream);
        }

        final participantCount = (_room?.remoteParticipants.length ?? 0) + 1;

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Video display
              Positioned.fill(
                child: _remoteVideoTrack != null
                    ? VideoTrackRenderer(_remoteVideoTrack!)
                    : Container(
                  color: Colors.black,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam_off,
                          color: Colors.white54,
                          size: 64,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Đang chờ video...',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Reactions overlay
              ...(_reactions.map((r) => r.build())),

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
                          Colors.transparent
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "TRỰC TIẾP",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formatDuration(_getElapsedTime(stream)),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Viewer count
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.visibility,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '$participantCount',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Close button
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: _leaveLiveStream,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Streamer info
              Positioned(
                top: 80,
                left: 16,
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
                        backgroundImage: stream.avatarUrl != null
                            ? NetworkImage(stream.avatarUrl!)
                            : null,
                        child: stream.avatarUrl == null
                            ? const Icon(Icons.person,
                            color: Colors.white, size: 20)
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
              ),

              // Comments list
              Positioned(
                bottom: 160,
                left: 16,
                right: 16,
                height: 200,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    final comment = _comments[index];
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
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${comment.username}: ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: comment.comment,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Reaction buttons
              Positioned(
                right: 12,
                bottom: 200,
                child: Column(
                  children: [
                    _buildReactionButton('❤️', () => _addReaction('❤️')),
                    const SizedBox(height: 12),
                    _buildReactionButton('😂', () => _addReaction('😂')),
                    const SizedBox(height: 12),
                    _buildReactionButton('😮', () => _addReaction('😮')),
                    const SizedBox(height: 12),
                    _buildReactionButton('👏', () => _addReaction('👏')),
                    const SizedBox(height: 12),
                    _buildReactionButton('🔥', () => _addReaction('🔥')),
                  ],
                ),
              ),

              // Bottom bar - Comment input
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent
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
                                hintText: 'Thêm bình luận...',
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildReactionButton(String emoji, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}

// Comment model
class CommentItem {
  final String username;
  final String comment;
  final DateTime timestamp;

  CommentItem({
    required this.username,
    required this.comment,
    required this.timestamp,
  });
}

// Reaction animation
class ReactionAnimation {
  final String emoji;
  final DateTime createdAt;
  final double startX;
  final double endY;

  ReactionAnimation({required this.emoji})
      : createdAt = DateTime.now(),
        startX = 50 + (DateTime.now().millisecondsSinceEpoch % 200).toDouble(),
        endY = -200;

  bool isExpired() {
    return DateTime.now().difference(createdAt).inSeconds > 3;
  }

  Widget build() {
    final elapsed = DateTime.now().difference(createdAt).inMilliseconds;
    final progress = (elapsed / 3000).clamp(0.0, 1.0);

    return Positioned(
      right: startX,
      bottom: 200 - (progress * 400), // Move up
      child: Opacity(
        opacity: 1 - progress, // Fade out
        child: Transform.scale(
          scale: 1 + (progress * 0.5), // Scale up slightly
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
        ),
      ),
    );
  }
}