import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/snack_bar.dart';
import '../../domain/repository/live_comment_repo.dart';
import '../../domain/repository/live_reaction_repo.dart';
import '../../domain/repository/live_viewer_repository.dart';
import '../provider/block_user_cubit.dart';
import '../provider/live_comment_cubit.dart';
import '../provider/live_reaction_cubit.dart';
import '../provider/live_stream_cubit.dart';
import '../provider/live_stream_state.dart';
import '../provider/live_viewer_cubit.dart';
import '../provider/start_live_cubit.dart';
import 'live_streaming_page.dart';

class LivePrepScreen extends StatefulWidget {
  const LivePrepScreen({Key? key}) : super(key: key);

  @override
  State<LivePrepScreen> createState() => _LivePrepScreenState();
}

class _LivePrepScreenState extends State<LivePrepScreen> {
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeTracks();
  }

  Future<void> _initializeTracks() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    try {
      final videoTrack = await LocalVideoTrack.createCameraTrack(
        const CameraCaptureOptions(cameraPosition: CameraPosition.front),
      );
      await Future.delayed(const Duration(milliseconds: 300));

      final audioTrack = await LocalAudioTrack.create(
        AudioCaptureOptions(
          noiseSuppression: true,
          echoCancellation: true,
          autoGainControl: true,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;

      context.read<LiveStreamCubit>().setTracks(videoTrack, audioTrack);
    } catch (e) {
      print('Error initializing tracks: $e');
      if (mounted) {
        showCustomSnackBar(context, "Không thể khởi tạo camera/microphone");
      }
    }
  }

  void _startLiveStream() {
    final state = context.read<LiveStreamCubit>().state;

    if (state.localVideoTrack == null) {
      showCustomSnackBar(context, 'Camera chưa sẵn sàng');
      return;
    }
    if (state.localAudioTrack == null) {
      showCustomSnackBar(context, 'Microphone chưa sẵn sàng');
      return;
    }

    context.read<StartLiveCubit>().startLive(_descriptionController.text);
  }

  Future<void> _handleClose() async {
    await context.read<LiveStreamCubit>().disposeTracksOnly();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: MultiBlocListener(
        listeners: [
          BlocListener<StartLiveCubit, StartLiveState>(
            listener: (context, startState) {
              if (startState.stream != null) {
                final liveStreamCubit = context.read<LiveStreamCubit>();
                final state = liveStreamCubit.state;

                if (state.localVideoTrack == null ||
                    state.localAudioTrack == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thiết bị không sẵn sàng')),
                  );
                  return;
                }

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider<LiveStreamCubit>.value(
                          value: liveStreamCubit,
                        ),
                        BlocProvider(
                          create: (_) => LiveReactionCubit(
                            getIt<LiveReactionRepository>(),
                            startState.stream!.id,
                          ),
                        ),
                        BlocProvider(
                          create: (_) => LiveCommentCubit(
                            getIt<LiveCommentRepository>(),
                            startState.stream!.id,
                          ),
                        ),
                        BlocProvider(
                          create: (_) => LiveViewerCubit(
                            getIt<LiveViewerRepository>(),
                            startState.stream!.id,
                          ),
                        ),
                        BlocProvider(
                          create: (_) => BlockUserCubit(),
                        ),
                      ],
                      child: LiveStreamScreen(stream: startState.stream!),
                    ),
                  ),
                );
              }

              if (startState.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(startState.error!)),
                );
              }
            },
          ),
          BlocListener<LiveStreamCubit, LiveStreamState>(
            listenWhen: (previous, current) => previous.error != current.error,
            listener: (context, state) {
              if (state.error != null) {
                showCustomSnackBar(context, state.error!);
              }
            },
          ),
        ],
        child: BlocBuilder<LiveStreamCubit, LiveStreamState>(
          builder: (context, state) {
            return Stack(
              children: [
                // Preview camera
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

                // Top bar
                _buildTopBar(),

                // Control buttons (right side)
                _buildRightControls(state),

                // Bottom section
                _buildBottomSection(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
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
                onPressed: _handleClose,
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
    );
  }

  Widget _buildRightControls(LiveStreamState state) {
    return Positioned(
      right: 16,
      top: 0,
      bottom: 200,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(
              icon: state.isCameraOn ? Icons.videocam : Icons.videocam_off,
              label: 'Camera',
              onPressed: () => context.read<LiveStreamCubit>().toggleCamera(),
            ),
            const SizedBox(height: 20),
            _buildControlButton(
              icon: state.isMicOn ? Icons.mic : Icons.mic_off,
              label: state.isMicOn ? 'Tắt micro' : 'Bật micro',
              onPressed: () => context.read<LiveStreamCubit>().toggleMic(),
            ),
            const SizedBox(height: 20),
            _buildControlButton(
              icon: Icons.cameraswitch,
              label: 'Xoay',
              onPressed: () => context.read<LiveStreamCubit>().switchCamera(),
            ),
            _buildControlButton(
              icon: state.isFlashOn ? Icons.flash_on : Icons.flash_off,
              label: 'Flash',
              onPressed: () => context.read<LiveStreamCubit>().toggleFlash(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Positioned(
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
              decoration: const InputDecoration(
                hintText: 'Thêm mô tả...',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.share, color: Colors.white),
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
            BlocBuilder<StartLiveCubit, StartLiveState>(
              builder: (context, startState) {
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: startState.loading ? null : _startLiveStream,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: startState.loading
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : const Text(
                      'Phát trực tiếp',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
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
          decoration: const BoxDecoration(
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
            style: const TextStyle(color: Colors.white, fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}