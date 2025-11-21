import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../data/models/recipe_detail_model.dart';

class StepsTab extends StatelessWidget {
  final RecipeDetailModel recipe;
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

                //Hinh minh hoa
                if (step.imageUrls != null && step.imageUrls!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: step.imageUrls!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  step.imageUrls![index],
                                  fit: BoxFit.cover,
                                  width: 200,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 150,
                                      width: 200,
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
                          );
                        },
                      ),
                    ),
                  ),
                //video huong dan
                if (step.videoUrls != null && step.videoUrls!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: step.videoUrls!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _StepVideoPlayer(
                              videoUrl: step.videoUrls![index],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
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
