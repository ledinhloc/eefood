import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class StepsTab extends StatelessWidget {
  final dynamic recipe;
  const StepsTab({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: recipe.steps?.length ?? 0,
      itemBuilder: (context, index) {
        final step = recipe.steps![index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bước ${step.stepNumber}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  step.instruction ?? '',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),

                // Thời gian của bước
                if (step.stepTime != null)
                  Text(
                    "⏱ ${step.stepTime} phút",
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),

                // Hình minh họa
                if (step.imageUrl != null && step.imageUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        step.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // Video hướng dẫn (nếu có)
                if (step.videoUrl != null && step.videoUrl!.isNotEmpty)
                  _StepVideoPlayer(videoUrl: step.videoUrl!),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StepVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const _StepVideoPlayer({required this.videoUrl});

  @override
  State<_StepVideoPlayer> createState() => _StepVideoPlayerState();
}

class _StepVideoPlayerState extends State<_StepVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller),
                IconButton(
                  icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause_circle
                        : Icons.play_circle,
                    size: 48,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                ),
              ],
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
