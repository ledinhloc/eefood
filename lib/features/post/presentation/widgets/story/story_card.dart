import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class StoryCard extends StatefulWidget {
  final String userName;
  final String? subTitle;
  final String imageUrl;
  final bool hasStory;
  final String? avatarUrl;
  const StoryCard({
    super.key,
    required this.userName,
    this.subTitle,
    required this.imageUrl,
    this.hasStory = false,
    this.avatarUrl,
  });

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: CachedNetworkImageProvider(widget.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
          ),
        ),
        child: Stack(
          children: [
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
                          errorWidget: (context, url, error) => const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 18,
                          ),
                        )
                      : const Icon(Icons.person, color: Colors.white, size: 18),
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
    );
  }
}
