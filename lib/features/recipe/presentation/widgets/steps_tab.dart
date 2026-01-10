import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/widgets/media_view_page.dart';
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

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Title ---
              Text(
                "Bước ${step.stepNumber}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.orange.shade700,
                ),
              ),

              const SizedBox(height: 8),

              // --- Instruction ---
              Text(
                step.instruction ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 10),

              // --- Step time ---
              if (step.stepTime != null)
                Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${step.stepTime} phút",
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),

              // --- Images ---
              if (step.imageUrls != null && step.imageUrls!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    height: 200,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: step.imageUrls!.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, imgIndex) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MediaViewPage(
                                  url: step.imageUrls![imgIndex],
                                  isVideo: false,
                                  isLocal: false,
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: step.imageUrls![imgIndex],
                              fit: BoxFit.cover,
                              width: 220,
                              placeholder: (context, url) => Container(
                                width: 220,
                                height: 200,
                                color: Colors.grey[100],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[200],
                                width: 220,
                                child: const Icon(Icons.broken_image, size: 48),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // --- Videos ---
              if (step.videoUrls != null && step.videoUrls!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    height: 200,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: step.videoUrls!.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
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
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    size: 50,
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
              ),
            ],
          )
        : Container(
            height: 200,
            color: Colors.black12,
            child: const Center(child: CircularProgressIndicator()),
          );
  }
}
