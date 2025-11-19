import 'package:cached_network_image/cached_network_image.dart';
import 'package:eefood/features/post/data/models/user_story_model.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class StoryContent extends StatefulWidget {
  final PageController pageController;
  final UserStoryModel user;
  final int initialStoryIndex;
  final Function(Duration?) onVideoProgress; // callback cho progress

  const StoryContent({
    super.key,
    required this.pageController,
    required this.user,
    required this.initialStoryIndex,
    required this.onVideoProgress,
  });

  @override
  State<StoryContent> createState() => _StoryContentState();
}

class _StoryContentState extends State<StoryContent> {
  VideoPlayerController? _videoController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialStoryIndex;
    _initVideo(widget.user.stories[_currentIndex]);
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _initVideo(story) {
    _videoController?.dispose();
    _videoController = null;

    if (story.type == "video" &&
        story.contentUrl != null &&
        story.contentUrl!.isNotEmpty) {
      _videoController = VideoPlayerController.network(story.contentUrl!)
        ..initialize().then((_) {
          if (!mounted) return;
          setState(() {});
          _videoController?.play();

          widget.onVideoProgress(_videoController!.value.duration);

          // Khi video kết thúc → yêu cầu next story
          _videoController?.addListener(() {
            final v = _videoController!;
            if (v.value.position >= v.value.duration) {
              widget.onVideoProgress(Duration.zero); // báo hết video
            }
          });
        });
    } else {
      // Nếu là ảnh
      widget.onVideoProgress(const Duration(seconds: 5));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: widget.pageController,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.user.stories.length,
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
          _initVideo(widget.user.stories[_currentIndex]);
        });
      },
      itemBuilder: (_, i) {
        final s = widget.user.stories[i];
        if (s.type == "video") {
          if (_videoController != null &&
              _videoController!.value.isInitialized) {
            return SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
        } else {
          return CachedNetworkImage(
            imageUrl: s.contentUrl ?? "",
            fit: BoxFit.cover,
            fadeInDuration: Duration.zero,
            placeholderFadeInDuration: Duration.zero,
          );
        }
      },
    );
  }
}
