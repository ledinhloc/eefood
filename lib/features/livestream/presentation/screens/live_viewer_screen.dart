import 'dart:async';
import 'dart:developer' as developer;

import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/core/utils/helpers.dart';
import 'package:eefood/features/livestream/presentation/widgets/live_comment_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../../../core/di/injection.dart';
import '../../data/model/live_stream_response.dart';
import '../provider/watch_live_cubit.dart';

class LiveViewerScreen extends StatefulWidget {
  final int streamId;

  const LiveViewerScreen({Key? key, required this.streamId}) : super(key: key);

  @override
  State<LiveViewerScreen> createState() => _LiveViewerScreenState();
}

class _LiveViewerScreenState extends State<LiveViewerScreen> {
  Room? _room;
  RemoteVideoTrack? _remoteVideoTrack;
  RemoteAudioTrack? _remoteAudioTrack;
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _hasAttemptedConnection = false;
  Timer? _timer;
  // final List<CommentItem> _comments = [];
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Reactions
  final List<ReactionAnimation> _reactions = [];
  Timer? _reactionTimer;
  EventsListener<RoomEvent>? _listener;

  @override
  void initState() {
    super.initState();
    developer.log('[VIEWER] initState called', name: 'LiveViewer');
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
    developer.log('[VIEWER] Loading stream...', name: 'LiveViewer');

    try {
      await context.read<WatchLiveCubit>().loadLive(widget.streamId);
      developer.log('[VIEWER] Stream loaded successfully', name: 'LiveViewer');

      // Connect sau khi load stream xong
      final stream = context.read<WatchLiveCubit>().state.stream;

      if (stream != null) {
        developer.log(
          '[VIEWER] Stream data: title=${stream.title}, token=${stream.livekitToken != null ? "exists" : "null"}',
          name: 'LiveViewer',
        );

        if (stream.livekitToken != null) {
          await _connectToRoom(stream);
        } else {
          developer.log('[VIEWER] No livekit token found', name: 'LiveViewer');
        }
      } else {
        developer.log(' [VIEWER] Stream is null', name: 'LiveViewer');
      }
    } catch (e, stackTrace) {
      developer.log(
        ' [VIEWER] Error loading stream: $e',
        name: 'LiveViewer',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _connectToRoom(LiveStreamResponse stream) async {
    if (_isConnected || _isConnecting || _hasAttemptedConnection) {
      developer.log(
        '[VIEWER] Skip connection - connected:$_isConnected, connecting:$_isConnecting, attempted:$_hasAttemptedConnection',
        name: 'LiveViewer',
      );
      return;
    }

    developer.log('[VIEWER] Starting connection...', name: 'LiveViewer');

    setState(() {
      _isConnecting = true;
      _hasAttemptedConnection = true;
    });

    try {
      _room = Room(
        roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true),
      );

      developer.log('[VIEWER] Room created', name: 'LiveViewer');

      _listener = _room!.createListener();

      developer.log(
        '[VIEWER] Setting up event listeners...',
        name: 'LiveViewer',
      );

      _listener!
        //streamer đã vào room
        ..on<ParticipantConnectedEvent>((event) {
          developer.log(
            '[VIEWER] Participant connected: ${event.participant.identity}',
            name: 'LiveViewer',
          );
          _handleRemoteParticipant(event.participant);
        })
        //viewer đã subscribe được video/audio
        ..on<TrackSubscribedEvent>((event) {
          developer.log(
            '[VIEWER] Track subscribed: ${event.track.kind}, sid: ${event.track.sid}',
            name: 'LiveViewer',
          );

          if (event.track is RemoteVideoTrack) {
            setState(() {
              _remoteVideoTrack = event.track as RemoteVideoTrack;
            });
            developer.log('[VIEWER] VIDEO TRACK ASSIGNED!', name: 'LiveViewer');
          } else if (event.track is RemoteAudioTrack) {
            setState(() {
              _remoteAudioTrack = event.track as RemoteAudioTrack;
            });
            developer.log('[VIEWER] AUDIO TRACK ASSIGNED!', name: 'LiveViewer');
          }
        })
        //streamer tắt cam/mic
        ..on<TrackUnsubscribedEvent>((event) {
          developer.log(
            '[VIEWER] Track unsubscribed: ${event.track.kind}',
            name: 'LiveViewer',
          );
          if (event.track is RemoteVideoTrack) {
            setState(() {
              _remoteVideoTrack = null;
            });
          }
        })
        //mất kết nối / streamer end live
        ..on<RoomDisconnectedEvent>((event) {
          developer.log(
            '[VIEWER] Room disconnected: ${event.reason}',
            name: 'LiveViewer',
          );
          setState(() {
            _isConnected = false;
            _isConnecting = false;
          });
        })
        ..on<ParticipantDisconnectedEvent>((event) {
          developer.log(
            ' [VIEWER] Participant disconnected: ${event.participant.identity}',
            name: 'LiveViewer',
          );
        });

      // developer.log('[VIEWER] Connecting to: ${AppKeys.livekitUrl}', name: 'LiveViewer');
      // developer.log('[VIEWER] Token (first 30 chars): ${stream.livekitToken!.substring(0, stream.livekitToken!.length > 30 ? 30 : stream.livekitToken!.length)}...', name: 'LiveViewer');

      await _room!.connect(
        AppKeys.livekitUrl,
        stream.livekitToken!,
        connectOptions: const ConnectOptions(autoSubscribe: true),
      );

      developer.log(
        '[VIEWER] Connected! State: ${_room!.connectionState}',
        name: 'LiveViewer',
      );
      developer.log(
        '[VIEWER] Remote participants: ${_room!.remoteParticipants.length}',
        name: 'LiveViewer',
      );

      // List all participants
      _room!.remoteParticipants.forEach((sid, participant) {
        developer.log(
          ' [VIEWER] Participant - SID: $sid, Identity: ${participant.identity}',
          name: 'LiveViewer',
        );
        developer.log(
          '    Video tracks: ${participant.videoTrackPublications.length}',
          name: 'LiveViewer',
        );
        developer.log(
          '    Audio tracks: ${participant.audioTrackPublications.length}',
          name: 'LiveViewer',
        );

        // Log chi tiết từng track
        for (var pub in participant.videoTrackPublications) {
          developer.log(
            '       Video pub - sid: ${pub.sid}, subscribed: ${pub.subscribed}, muted: ${pub.muted}',
            name: 'LiveViewer',
          );
        }
      });

      // Đợi 1 giây để tracks được subscribe
      developer.log(
        ' [VIEWER] Waiting for tracks to be ready...',
        name: 'LiveViewer',
      );
      await Future.delayed(const Duration(seconds: 2));

      // Handle existing participants
      for (var participant in _room!.remoteParticipants.values) {
        developer.log(
          ' [VIEWER] Processing existing participant: ${participant.identity}',
          name: 'LiveViewer',
        );
        _handleRemoteParticipant(participant);
      }

      setState(() {
        _isConnected = true;
        _isConnecting = false;
      });

      developer.log(' [VIEWER] Connection setup complete!', name: 'LiveViewer');
    } catch (e, stackTrace) {
      developer.log(
        ' [VIEWER] Connection error',
        name: 'LiveViewer',
        error: e,
        stackTrace: stackTrace,
      );

      setState(() {
        _isConnecting = false;
        _hasAttemptedConnection = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi kết nối: $e')));
      }
    }
  }

  //Lắng nghe mọi thay đổi của streamer
  void _handleRemoteParticipant(RemoteParticipant participant) {
    developer.log(
      ' [VIEWER] Handling participant: ${participant.identity}',
      name: 'LiveViewer',
    );
    developer.log(
      '    Video publications: ${participant.videoTrackPublications.length}',
      name: 'LiveViewer',
    );
    developer.log(
      '    Audio publications: ${participant.audioTrackPublications.length}',
      name: 'LiveViewer',
    );

    // Add listener cho participant
    participant.addListener(() {
      developer.log(
        ' [VIEWER] Participant state changed: ${participant.identity}',
        name: 'LiveViewer',
      );

      for (var pub in participant.videoTrackPublications) {
        developer.log(
          '    Video - subscribed: ${pub.subscribed}, muted: ${pub.muted}, hasTrack: ${pub.track != null}',
          name: 'LiveViewer',
        );

        if (pub.track != null && pub.subscribed && !pub.muted) {
          if (_remoteVideoTrack != pub.track) {
            setState(() {
              _remoteVideoTrack = pub.track as RemoteVideoTrack;
            });
            developer.log(
              '       NEW Video track assigned in listener!',
              name: 'LiveViewer',
            );
          }
        }
      }

      for (var pub in participant.audioTrackPublications) {
        if (pub.track != null && pub.subscribed) {
          if (_remoteAudioTrack != pub.track) {
            setState(() {
              _remoteAudioTrack = pub.track as RemoteAudioTrack;
            });
            developer.log(
              '    NEW Audio track assigned in listener!',
              name: 'LiveViewer',
            );
          }
        }
      }
    });

    // Check existing tracks immediately
    for (var pub in participant.videoTrackPublications) {
      developer.log(
        '    [VIEWER] Checking video track - subscribed: ${pub.subscribed}, sid: ${pub.sid}, hasTrack: ${pub.track != null}',
        name: 'LiveViewer',
      );

      if (pub.track != null && pub.subscribed) {
        setState(() {
          _remoteVideoTrack = pub.track as RemoteVideoTrack;
        });
        developer.log(
          '       Initial video track assigned!',
          name: 'LiveViewer',
        );
      } else if (!pub.subscribed) {
        developer.log(
          '      [VIEWER] Track not subscribed, attempting subscribe...',
          name: 'LiveViewer',
        );
        try {
          pub.subscribe();
        } catch (e) {
          developer.log('   ❌ Failed to subscribe: $e', name: 'LiveViewer');
        }
      }
    }

    for (var pub in participant.audioTrackPublications) {
      if (pub.track != null && pub.subscribed) {
        setState(() {
          _remoteAudioTrack = pub.track as RemoteAudioTrack;
        });
        developer.log(
          '      Initial audio track assigned!',
          name: 'LiveViewer',
        );
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
        content: const Text(
          'Bạn có chắc muốn rời khỏi phiên phát trực tiếp này?',
        ),
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
      developer.log(' [VIEWER] Leaving stream...', name: 'LiveViewer');
      await _room?.disconnect();
      await _room?.dispose();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    developer.log('[VIEWER] Disposing...', name: 'LiveViewer');
    _timer?.cancel();
    _reactionTimer?.cancel();
    _listener?.dispose();
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
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
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
                      setState(() {
                        _hasAttemptedConnection = false;
                      });
                      _loadStream();
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
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isConnecting ? Icons.sync : Icons.videocam_off,
                                color: Colors.white54,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _isConnecting
                                    ? 'Đang kết nối...'
                                    : _isConnected
                                    ? 'Đang chờ video...'
                                    : 'Chưa kết nối',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 16,
                                ),
                              ),
                              if (_isConnecting)
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
                              const Icon(
                                Icons.visibility,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$participantCount',
                                style: const TextStyle(
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
                          onPressed: _leaveLiveStream,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Streamer info
              Positioned(
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
                        backgroundImage: stream.avatarUrl != null
                            ? NetworkImage(stream.avatarUrl!)
                            : null,
                        child: stream.avatarUrl == null
                            ? const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20,
                              )
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
                bottom: 30,
                  left: 10,
                  right: 16,
                  height: 400,
                  child: LiveCommentList(
                      controller: _commentController,
                      scrollController: _scrollController
                  )
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
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
      ),
    );
  }
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
          child: Text(emoji, style: const TextStyle(fontSize: 32)),
        ),
      ),
    );
  }
}
