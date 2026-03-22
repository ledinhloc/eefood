import 'dart:async';

import 'package:eefood/features/livestream/presentation/provider/live_viewer_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../../../core/constants/app_keys.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/snack_bar.dart';
import '../../data/model/live_reaction_response.dart';
import '../../data/model/live_stream_response.dart';
import '../provider/block_user_cubit.dart';
import '../provider/live_poll_cubit.dart';
import '../provider/live_poll_state.dart';
import '../provider/live_reaction_cubit.dart';
import '../provider/live_reaction_state.dart';
import '../provider/live_stream_cubit.dart';
import '../provider/live_stream_state.dart';
import '../provider/start_live_cubit.dart';
import '../widgets/create_poll_bottom_sheet.dart';
import '../widgets/live_comment_list.dart';
import '../widgets/live_poll/live_poll_banner.dart';
import '../widgets/live_poll/live_poll_manage_bottom_sheet.dart';
import '../widgets/live_reaction_animation.dart';
import '../widgets/live_status_timer.dart';
import '../widgets/viewer_list_bottom_sheet.dart';

class LiveStreamScreen extends StatefulWidget {
  final LiveStreamResponse stream;

  const LiveStreamScreen({super.key, required this.stream});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<List<LiveReactionResponse>> _activeReactions =
      ValueNotifier<List<LiveReactionResponse>>([]);

  late final LiveViewerCubit _liveViewerCubit;
  late final LiveStreamCubit _liveStreamCubit;

  bool _isCleaningUp = false;
  bool _cleanupCompleted = false;
  bool _liveEndedOnServer = false;

  @override
  void initState() {
    super.initState();
    _liveViewerCubit = context.read<LiveViewerCubit>();
    _liveStreamCubit = context.read<LiveStreamCubit>();
    _ensureTracksReady();
    _liveViewerCubit.joinLiveStream();
  }

  Future<void> _ensureTracksReady() async {
    final state = _liveStreamCubit.state;

    if (state.localVideoTrack != null && state.localAudioTrack != null) {
      await _liveStreamCubit.connectToRoom(
        AppKeys.livekitUrl,
        widget.stream.livekitToken!,
      );
      return;
    }

    try {
      final videoTrack = await LocalVideoTrack.createCameraTrack(
        CameraCaptureOptions(
          cameraPosition: state.isFrontCamera
              ? CameraPosition.front
              : CameraPosition.back,
          params: VideoParametersPresets.h540_169,
          maxFrameRate: 24,
        ),
      );

      final audioTrack = await LocalAudioTrack.create(
        AudioCaptureOptions(
          noiseSuppression: true,
          echoCancellation: true,
          autoGainControl: true,
        ),
      );

      _liveStreamCubit.setTracks(videoTrack, audioTrack);
    } catch (_) {
      if (mounted) {
        showCustomSnackBar(context, 'Khong the khoi tao camera/microphone');
      }
      return;
    }

    await _liveStreamCubit.connectToRoom(
      AppKeys.livekitUrl,
      widget.stream.livekitToken!,
    );
  }

  Future<bool> _confirmEndLive() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ket thuc phat truc tiep?'),
        content: const Text(
          'Ban co chac muon ket thuc phien phat truc tiep nay?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ket thuc'),
          ),
        ],
      ),
    );

    return confirm ?? false;
  }

  Future<void> _cleanupLiveSession({bool endLiveOnServer = false}) async {
    if (_cleanupCompleted || _isCleaningUp) {
      return;
    }

    _isCleaningUp = true;

    try {
      await _liveStreamCubit.disconnect();
    } catch (_) {}

    try {
      await _liveViewerCubit.leaveLiveStream();
    } catch (_) {}

    if (endLiveOnServer && !_liveEndedOnServer) {
      try {
        await getIt<StartLiveCubit>().endLive(widget.stream.id);
        _liveEndedOnServer = true;
      } catch (_) {}
    }

    _cleanupCompleted = true;
    _isCleaningUp = false;
  }

  Future<void> _leaveLiveScreenTemporarily() async {
    final state = _liveStreamCubit.state;

    try {
      if (state.isCameraOn) {
        await _liveStreamCubit.toggleCamera();
      }
    } catch (_) {}

    try {
      if (state.isMicOn) {
        await _liveStreamCubit.toggleMic();
      }
    } catch (_) {}

    if (!mounted) return;
    Navigator.pop(context, false);
  }

  Future<void> _endLiveStream() async {
    final confirm = await _confirmEndLive();
    if (!confirm || !mounted) return;

    await _cleanupLiveSession(endLiveOnServer: true);
    if (!mounted) return;

    Navigator.pop(context, true);
  }

  Future<bool> _handleBackNavigation() async {
    await _leaveLiveScreenTemporarily();
    return false;
  }

  void _showCreatePollSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: context.read<LivePollCubit>(),
          child: const CreatePollBottomSheet(),
        );
      },
    );
  }

  void _showPollManageSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: context.read<LivePollCubit>(),
          child: LivePollManageBottomSheet(
            onCreateNewPoll: _showCreatePollSheet,
          ),
        );
      },
    );
  }

  void _appendReactions(List<LiveReactionResponse> reactions) {
    final current = _activeReactions.value;
    final activeIds = current.map((reaction) => reaction.id).toSet();
    final incoming = reactions
        .where((reaction) => !activeIds.contains(reaction.id))
        .toList();

    if (incoming.isEmpty) return;

    _activeReactions.value = List<LiveReactionResponse>.of(current)
      ..addAll(incoming);
  }

  void _onReactionCompleted(LiveReactionResponse reaction) {
    _activeReactions.value = _activeReactions.value
        .where((item) => item.id != reaction.id)
        .toList();
  }

  void _showViewerList() {
    final viewerCubit = context.read<LiveViewerCubit>();
    final blockCubit = context.read<BlockUserCubit>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: viewerCubit),
            BlocProvider.value(value: blockCubit),
          ],
          child: const ViewerListBottomSheet(),
        );
      },
    );
  }

  @override
  void dispose() {
    if (_liveEndedOnServer && !_cleanupCompleted) {
      unawaited(_cleanupLiveSession(endLiveOnServer: true));
    }
    _commentController.dispose();
    _scrollController.dispose();
    _activeReactions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackNavigation();
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<LiveReactionCubit, LiveReactionState>(
            listener: (context, reactionState) {
              if (reactionState.reactions.isNotEmpty) {
                _appendReactions(reactionState.reactions);
              }
            },
          ),
          BlocListener<LiveStreamCubit, LiveStreamState>(
            listenWhen: (previous, current) => previous.error != current.error,
            listener: (context, state) {
              if (state.error != null) {
                showCustomSnackBar(context, state.error!, isError: true);
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              const Positioned.fill(child: _LiveVideoView()),
              Positioned.fill(
                child: _ReactionLayer(
                  reactions: _activeReactions,
                  onComplete: _onReactionCompleted,
                ),
              ),
              _LiveTopBar(
                stream: widget.stream,
                onEndLive: _endLiveStream,
                onShowViewerList: _showViewerList,
                onShowPollManage: _showPollManageSheet,
              ),
              Positioned(
                bottom: 30,
                left: 10,
                right: 16,
                height: 400,
                child: LiveCommentList(
                  controller: _commentController,
                  scrollController: _scrollController,
                  isStreamer: true,
                  inputBackgroundColor: Colors.transparent,
                ),
              ),
              _LiveRightControls(
                onShowCreatePoll: _showCreatePollSheet,
                onShowPollManage: _showPollManageSheet,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveVideoView extends StatelessWidget {
  const _LiveVideoView();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      LiveStreamCubit,
      LiveStreamState,
      (LocalVideoTrack?, bool)
    >(
      selector: (state) => (state.localVideoTrack, state.isCameraOn),
      builder: (context, videoState) {
        final track = videoState.$1;
        final isCameraOn = videoState.$2;

        if (track != null && isCameraOn) {
          return VideoTrackRenderer(track);
        }

        return Container(
          color: Colors.black,
          child: const Center(
            child: Icon(Icons.videocam_off, color: Colors.white, size: 64),
          ),
        );
      },
    );
  }
}

class _ReactionLayer extends StatelessWidget {
  final ValueNotifier<List<LiveReactionResponse>> reactions;
  final ValueChanged<LiveReactionResponse> onComplete;

  const _ReactionLayer({required this.reactions, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ValueListenableBuilder<List<LiveReactionResponse>>(
        valueListenable: reactions,
        builder: (context, items, child) {
          return Stack(
            children: items
                .map(
                  (reaction) => LiveReactionAnimation(
                    key: ValueKey(reaction.id),
                    reaction: reaction,
                    onComplete: () => onComplete(reaction),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class _LiveTopBar extends StatelessWidget {
  final LiveStreamResponse stream;
  final VoidCallback onEndLive;
  final VoidCallback onShowViewerList;
  final VoidCallback onShowPollManage;

  const _LiveTopBar({
    required this.stream,
    required this.onEndLive,
    required this.onShowViewerList,
    required this.onShowPollManage,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: BlocSelector<LiveStreamCubit, LiveStreamState, int>(
          selector: (state) => state.viewerCount,
          builder: (context, participantCount) {
            return BlocBuilder<LivePollCubit, LivePollState>(
              builder: (context, pollState) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          LiveStatusTimer(startTime: stream.startedAt!),
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
                                  'Chi minh toi',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _ViewerCountChip(
                            participantCount: participantCount,
                            onTap: onShowViewerList,
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: onEndLive,
                          ),
                        ],
                      ),
                      if (pollState.poll != null) ...[
                        const SizedBox(height: 10),
                        LivePollBanner(
                          poll: pollState.poll!,
                          onTap: onShowPollManage,
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ViewerCountChip extends StatelessWidget {
  final int participantCount;
  final VoidCallback onTap;

  const _ViewerCountChip({required this.participantCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
}

class _LiveRightControls extends StatelessWidget {
  final VoidCallback onShowCreatePoll;
  final VoidCallback onShowPollManage;

  const _LiveRightControls({
    required this.onShowCreatePoll,
    required this.onShowPollManage,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 12,
      bottom: 120,
      child:
          BlocSelector<
            LiveStreamCubit,
            LiveStreamState,
            ({bool isCameraOn, bool isMicOn, bool isFlashOn})
          >(
            selector: (state) => (
              isCameraOn: state.isCameraOn,
              isMicOn: state.isMicOn,
              isFlashOn: state.isFlashOn,
            ),
            builder: (context, state) {
              return Column(
                children: [
                  _RoundButton(
                    icon: Icons.poll_outlined,
                    onPressed: () {
                      final poll = context.read<LivePollCubit>().state.poll;
                      if (poll != null) {
                        onShowPollManage();
                        return;
                      }
                      onShowCreatePoll();
                    },
                  ),
                  const SizedBox(height: 10),
                  _RoundButton(
                    icon: state.isCameraOn
                        ? Icons.videocam
                        : Icons.videocam_off,
                    onPressed: () =>
                        context.read<LiveStreamCubit>().toggleCamera(),
                  ),
                  const SizedBox(height: 10),
                  _RoundButton(
                    icon: Icons.cameraswitch,
                    onPressed: () =>
                        context.read<LiveStreamCubit>().switchCamera(),
                  ),
                  const SizedBox(height: 10),
                  _RoundButton(
                    icon: state.isFlashOn ? Icons.flash_on : Icons.flash_off,
                    onPressed: () =>
                        context.read<LiveStreamCubit>().toggleFlash(),
                  ),
                  const SizedBox(height: 10),
                  _RoundButton(
                    icon: state.isMicOn ? Icons.mic : Icons.mic_off,
                    onPressed: () =>
                        context.read<LiveStreamCubit>().toggleMic(),
                  ),
                ],
              );
            },
          ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _RoundButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
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
