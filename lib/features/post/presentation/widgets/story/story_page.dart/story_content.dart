import 'package:cached_network_image/cached_network_image.dart';
import 'package:eefood/features/post/data/models/story_model.dart';
import 'package:eefood/features/post/data/models/user_story_model.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class StoryContent extends StatefulWidget {
  final PageController pageController;
  final UserStoryModel user;
  final int initialStoryIndex;
  final Function(Duration?) onVideoProgress;

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
  bool _hasNotifiedVideoEnd = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialStoryIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initStory(widget.user.stories[_currentIndex]);
    });
  }

  @override
  void dispose() {
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    super.dispose();
  }

  void _videoListener() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return;
    }

    final position = _videoController!.value.position;
    final duration = _videoController!.value.duration;

    // Kiểm tra video đã kết thúc (với buffer 100ms)
    if (!_hasNotifiedVideoEnd &&
        position >= duration - const Duration(milliseconds: 100)) {
      _hasNotifiedVideoEnd = true;
      debugPrint("Video ended, notifying completion");
    }
  }

  void _initStory(StoryModel story) {
    _hasNotifiedVideoEnd = false;

    if (story.type == "video" &&
        story.contentUrl != null &&
        story.contentUrl!.isNotEmpty) {
      _initVideo(story);
    } else {
      _initImage();
    }
  }

  void _initVideo(StoryModel story) {
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    _videoController = null;

    _videoController =
        VideoPlayerController.networkUrl(Uri.parse(story.contentUrl!))
          ..initialize()
              .then((_) {
                if (!mounted) return;

                setState(() {});

                final duration = _videoController!.value.duration;
                debugPrint("Video initialized: ${duration.inSeconds}s");

                // Start progress với duration của video
                widget.onVideoProgress(duration);

                // Add listener để track video end
                _videoController!.addListener(_videoListener);

                // Play video
                _videoController!.play();
              })
              .catchError((error) {
                debugPrint("Video initialization error: $error");
                // Nếu video lỗi, fallback về image với 5 giây
                _initImage();
              });
  }

  void _initImage() {
    debugPrint("Image story, using 8 seconds duration");
    // Image story dùng 8 giây mặc định
    widget.onVideoProgress(const Duration(seconds: 8));
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: widget.pageController,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.user.stories.length,
      onPageChanged: (index) {
        debugPrint("Story page changed to index: $index");
        setState(() {
          _currentIndex = index;
          _initStory(widget.user.stories[_currentIndex]);
        });
      },
      itemBuilder: (_, i) {
        final story = widget.user.stories[i];

        if (story.type == "video") {
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
            return Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            );
          }
        } else {
          // Image story
          return CachedNetworkImage(
            imageUrl: story.contentUrl ?? "",
            fit: BoxFit.cover,
            fadeInDuration: Duration.zero,
            placeholderFadeInDuration: Duration.zero,
            placeholder: (context, url) => Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.black,
              child: const Center(
                child: Icon(Icons.error_outline, color: Colors.white, size: 48),
              ),
            ),
          );
        }
      },
    );
  }
}
