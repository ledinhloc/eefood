import 'package:better_player_plus/better_player_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eefood/core/utils/better_player_utils.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class StoryCard extends StatefulWidget {
  final String userName;
  final String contentUrl;
  final bool hasStory;
  final String? avatarUrl;
  final bool isCreating;
  final bool isVideo;

  const StoryCard({
    super.key,
    required this.userName,
    required this.contentUrl,
    this.hasStory = false,
    this.avatarUrl,
    this.isCreating = false,
    this.isVideo = false,
  });

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard>
    with AutomaticKeepAliveClientMixin {
  BetterPlayerController? _betterController;

  @override
  void initState() {
    super.initState();
    debugPrint('Video story: ${widget.contentUrl}');
    _initVideoIfNeeded();
  }

  void _initVideoIfNeeded() {
    if (widget.isVideo) {
      _betterController?.dispose();
      _betterController = BetterPlayerUtils.create(
        url: widget.contentUrl,
        autoPlay: false,
        mute: true,
        looping: true,
        aspectRatio: 9 / 16,
      );
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant StoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contentUrl != widget.contentUrl ||
        oldWidget.isVideo != widget.isVideo) {
      _initVideoIfNeeded();
    }
  }

  void _handleVisibility(bool visible) {
    if (_betterController == null) return;

    if (visible) {
      _betterController!.play();
    } else {
      _betterController!.pause();
    }
  }

  @override
  void dispose() {
    _betterController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return VisibilityDetector(
      key: Key(widget.userName + widget.contentUrl),
      onVisibilityChanged: (visibilityInfo) {
        _handleVisibility(visibilityInfo.visibleFraction > 0.5);
      },
      child: Stack(
        children: [
          Container(
            width: 90,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: widget.contentUrl.isEmpty
                  ? Colors.grey[300]
                  : null,
              image: (!widget.isVideo && widget.contentUrl.isNotEmpty)
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(widget.contentUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  if (widget.isVideo && _betterController != null)
                    SizedBox.expand(
                      child: BetterPlayer(controller: _betterController!),
                    ),

                  // overlay gradient
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.65),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.hasStory ? Colors.blue : Colors.grey,
                          width: 2.5,
                        ),
                      ),
                      child: ClipOval(
                        child: widget.avatarUrl != null
                            ? CachedNetworkImage(
                                imageUrl: widget.avatarUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                              )
                            : const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 18,
                              ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    left: 6,
                    right: 6,
                    child: Text(
                      widget.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (widget.isCreating)
            Container(
              width: 90,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
