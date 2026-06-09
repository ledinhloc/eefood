import 'dart:async';

import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/livestream/presentation/provider/live_gift_cubit.dart';
import 'package:eefood/features/livestream/presentation/provider/live_leaderboard_cubit.dart';
import 'package:eefood/features/livestream/presentation/provider/live_poll_cubit.dart';
import 'package:eefood/features/livestream/presentation/provider/live_poll_state.dart';
import 'package:eefood/features/livestream/presentation/widgets/leaderboard/live_leaderboard_strip.dart';
import 'package:eefood/features/livestream/presentation/widgets/live_gift/live_gift_bottom_sheet.dart';
import 'package:eefood/features/livestream/presentation/widgets/live_gift/live_gift_overlay_layer.dart';
import 'package:eefood/features/livestream/presentation/widgets/live_poll/live_poll_viewer_bottom_sheet.dart';
import 'package:eefood/features/livestream/presentation/widgets/stream_ended_dialog.dart';
import 'package:eefood/features/payment/presentation/provider/wallet_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../../../core/utils/food_emotion_helper.dart';
import '../../data/model/live_reaction_response.dart';
import '../../data/model/live_stream_response.dart';
import '../../domain/enum/subtitle_language.dart';
import '../provider/live_reaction_cubit.dart';
import '../provider/live_reaction_state.dart';
import '../provider/live_viewer_cubit.dart';
import '../provider/subtitle_cubit.dart';
import '../provider/subtitle_state.dart';
import '../provider/watch_live_cubit.dart';
import '../provider/watch_live_state.dart';
import '../widgets/live_comment_list.dart';
import '../widgets/live_poll/live_poll_banner.dart';
import '../widgets/live_reaction_animation.dart';
import '../widgets/live_status_timer.dart';
import '../widgets/live_subtitle_language_selector.dart';
import '../widgets/live_subtitle_overlay.dart';
import '../widgets/viewer_list_bottom_sheet.dart';

class LiveViewerScreen extends StatefulWidget {
  final int streamId;

  const LiveViewerScreen({super.key, required this.streamId});

  @override
  State<LiveViewerScreen> createState() => _LiveViewerScreenState();
}

class _LiveViewerScreenState extends State<LiveViewerScreen> {
  Timer? _timer;
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<LiveReactionResponse> _activeReactions = [];

  late final SubtitleCubit _subtitleCubit;
  late final LiveLeaderboardCubit _leaderboardCubit;
  late final WalletCubit _walletCubit;

  @override
  void initState() {
    super.initState();

    _subtitleCubit = context.read<SubtitleCubit>();
    _subtitleCubit.attachToStream(widget.streamId);
    _subtitleCubit.ensureConnected();

    _leaderboardCubit = context.read<LiveLeaderboardCubit>();
    _leaderboardCubit.init(widget.streamId); // Load stream
    _walletCubit = getIt<WalletCubit>();

    // Load stream
    context.read<WatchLiveCubit>().loadLive(widget.streamId);
    // Join as viewer
    context.read<LiveViewerCubit>().joinLiveStream();
  }

  void _showPollSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<LivePollCubit>(),
          child: const LivePollViewerBottomSheet(),
        );
      },
    );
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
            Navigator.pop(context); // dong dialog
            Navigator.pop(context); // thoat man hinh
          },
        );
      },
    );
  }

  Future<void> _sendReaction(FoodEmotion emotion) async {
    try {
      await context.read<LiveReactionCubit>().createReaction(emotion);
    } catch (_) {}
  }

  void _onReactionCompleted(LiveReactionResponse reaction) {
    setState(() {
      _activeReactions.remove(reaction);
    });
  }

  void _leaveLiveStream() async {
    context.read<LiveViewerCubit>().leaveLiveStream();
    _subtitleCubit.disposeStream();
    await context.read<WatchLiveCubit>().disconnect();
    if (mounted) Navigator.pop(context);
  }

  void _showGiftSheet(stream) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<LiveGiftCubit>()),
          BlocProvider.value(value: _walletCubit..init(stream.userId)),
        ],
        child: const LiveGiftBottomSheet(),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _commentController.dispose();
    _scrollController.dispose();
    _leaderboardCubit.unsubscribe(widget.streamId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LivePollCubit, LivePollState>(
          listener: (context, pollState) {
            if (pollState.error != null && pollState.error!.isNotEmpty) {
              showCustomSnackBar(context, pollState.error!);
            }
          },
        ),
        BlocListener<LiveReactionCubit, LiveReactionState>(
          listener: (context, reactionState) {
            if (reactionState.reactions.isNotEmpty) {
              final newReactions = reactionState.reactions
                  .where(
                    (r) => !_activeReactions.any((active) => active.id == r.id),
                  )
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
        BlocListener<SubtitleCubit, SubtitleState>(
          listenWhen: (previous, current) =>
              previous.subtitleError != current.subtitleError,
          listener: (context, state) {
            final error = state.subtitleError;
            if (error != null && error.isNotEmpty) {
              showCustomSnackBar(context, error);
            }
          },
        ),
      ],
      child: BlocBuilder<WatchLiveCubit, WatchLiveState>(
        builder: (context, state) {
          final subtitleState = context.watch<SubtitleCubit>().state;
          if (state.loading) {
            return const _LiveViewerLoadingView(
              message: 'Đang tải livestream...',
            );
          }

          if (state.error != null) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi: ${state.error}',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SubtitleCubit>().attachToStream(
                          widget.streamId,
                        );
                        context.read<SubtitleCubit>().ensureConnected();
                        context.read<WatchLiveCubit>().loadLive(
                          widget.streamId,
                        );
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
          final participantCount =
              (state.room?.remoteParticipants.length ?? 0) + 1;

          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                // Video display
                Positioned.fill(child: _buildVideoLayer(state, stream)),

                // Reactions
                ..._activeReactions.map((reaction) {
                  return LiveReactionAnimation(
                    key: ValueKey(reaction.id),
                    reaction: reaction,
                    onComplete: () => _onReactionCompleted(reaction),
                  );
                }),

                // Top bar
                _buildTopBar(stream, participantCount, subtitleState),
                Positioned(
                  top: 120,
                  left: 10,
                  child: SafeArea(
                    child: LiveLeaderboardStrip(
                      livestreamId: widget.streamId,
                      isStreamer: false,
                    ),
                  ),
                ),
                Positioned(
                  top: 110,
                  left: 10,
                  right: 70,
                  child: SafeArea(
                    child: BlocBuilder<LivePollCubit, LivePollState>(
                      builder: (context, pollState) {
                        final poll = pollState.poll;
                        if (poll == null) return const SizedBox.shrink();

                        return LivePollBanner(
                          poll: poll,
                          onTap: _showPollSheet,
                        );
                      },
                    ),
                  ),
                ),

                // Streamer info
                _buildStreamerInfo(stream),

                // Subtitle overlay
                if (subtitleState.selectedSubtitleLanguage !=
                        SubtitleLanguage.off &&
                    subtitleState.latestSubtitle != null)
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 280,
                    child: SafeArea(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: LiveSubtitleOverlay(
                          subtitle: subtitleState.latestSubtitle!,
                        ),
                      ),
                    ),
                  ),

                // Comments
                Positioned(
                  bottom: 30,
                  left: 10,
                  right: 16,
                  height: 250,
                  child: LiveCommentList(
                    controller: _commentController,
                    scrollController: _scrollController,
                    inputBackgroundColor: Colors.transparent,
                  ),
                ),

                // Overlay gift
                LiveGiftOverlayLayer(
                  giftCatalog: context.read<LiveGiftCubit>().state.gifts,
                ),

                // Reaction buttons
                _buildReactionButtons(stream),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoLayer(WatchLiveState state, LiveStreamResponse stream) {
    if (stream.status != LiveStreamStatus.LIVE) {
      return _LiveViewerVideoPlaceholder(
        message: stream.status.messageVi,
        showSpinner: false,
      );
    }

    if (state.remoteVideoTrack != null) {
      return VideoTrackRenderer(state.remoteVideoTrack!);
    }

    return _LiveViewerVideoPlaceholder(
      message: state.isConnecting
          ? 'Đang kết nối livestream...'
          : state.isConnected
          ? 'Đang chờ video...'
          : 'Đang tải livestream...',
      showSpinner: state.isConnecting || !state.isConnected,
    );
  }

  Widget _buildTopBar(
    dynamic stream,
    int participantCount,
    SubtitleState state,
  ) {
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
              colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
            ),
          ),
          child: Row(
            children: [
              LiveStatusTimer(startTime: stream.startedAt!),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: null,
                child: Container(
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
              ),
              const Spacer(),
              LiveSubtitleLanguageSelector(
                state: state,
                tooltip: 'Chon phu de',
              ),
              const SizedBox(width: 4),
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

  Widget _buildStreamerInfo(dynamic stream) {
    return Positioned(
      top: 90,
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

  Widget _buildReactionButtons(stream) {
    return Positioned(
      right: 12,
      bottom: 200,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () => _showGiftSheet(stream),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C6AFF), Color(0xFFE040FB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C6AFF).withValues(alpha: 0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🎁', style: TextStyle(fontSize: 26)),
                ),
              ),
            ),
          ),
          ...FoodEmotion.values.map((emotion) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => _sendReaction(emotion),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: FoodEmotionHelper.getColor(
                      emotion,
                    ).withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: FoodEmotionHelper.getColor(
                        emotion,
                      ).withValues(alpha: 0.6),
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
          }),
        ],
      ),
    );
  }
}

class _LiveViewerLoadingView extends StatelessWidget {
  final String message;

  const _LiveViewerLoadingView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sync, color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.white54, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: CircularProgressIndicator(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveViewerVideoPlaceholder extends StatelessWidget {
  final String message;
  final bool showSpinner;

  const _LiveViewerVideoPlaceholder({
    required this.message,
    this.showSpinner = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                showSpinner ? Icons.sync : Icons.videocam_off,
                color: Colors.white54,
                size: 56,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              if (showSpinner)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: CircularProgressIndicator(color: Colors.white54),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
