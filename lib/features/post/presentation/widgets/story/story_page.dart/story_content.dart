import 'package:better_player_plus/better_player_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eefood/core/utils/better_player_utils.dart';
import 'package:eefood/features/post/data/models/story_model.dart';
import 'package:eefood/features/post/data/models/user_story_model.dart';
import 'package:flutter/material.dart';

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
  BetterPlayerController? _videoController;
  int _currentIndex = 0;

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
     _videoController?.pause();
    _videoController?.dispose();
    _videoController = null;
    super.dispose();
  }

  void _initStory(StoryModel story) {
    _videoController?.dispose();
    _videoController = null;

    if (story.type == "video" &&
        story.contentUrl != null &&
        story.contentUrl!.isNotEmpty) {
      _initVideo(story);
    } else {
      _initImage();
    }
  }

  void _initVideo(StoryModel story) {

    if (story.contentUrl == null || story.contentUrl!.isEmpty) return;

    _videoController = BetterPlayerUtils.create(
      url: story.contentUrl!,
      autoPlay: true,
      looping: false,
      mute: false,
    );

    _videoController!.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
        final duration =
            _videoController!.videoPlayerController?.value.duration;
        widget.onVideoProgress(duration);
      }

      if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
        debugPrint("Video ended");
      }
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
          if (_videoController != null) {
            return BetterPlayer(controller: _videoController!);
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
