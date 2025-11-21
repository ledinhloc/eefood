import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eefood/features/post/data/models/story_view_model.dart';
import 'package:flutter/material.dart';

class StoryViewerBar extends StatelessWidget {
  final int total;
  final List<StoryViewModel> viewers;
  final VoidCallback onOpenList;

  const StoryViewerBar({
    super.key,
    required this.total,
    required this.viewers,
    required this.onOpenList,
  });

  @override
  Widget build(BuildContext context) {
    final topFive = viewers.take(5).toList();
    final rest = total - topFive.length;

    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Text(
                  "$total người xem",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(width: 12),

                // Avatars overlap
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: onOpenList,
                    child: SizedBox(
                      height: 32,
                      child: Stack(
                        children: List.generate(topFive.length, (i) {
                          final v = topFive[i];
                          return Positioned(
                            key: ValueKey(v.id),
                            left: i * 22,
                            child: ViewerAvatar(url: v.avatarUrl),
                          );
                        }),
                      ),
                    ),
                  ),
                ),

                // +X button
                if (rest > 0)
                  GestureDetector(
                    onTap: onOpenList,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "+$rest",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ViewerAvatar extends StatelessWidget {
  final String? url;
  const ViewerAvatar({super.key, this.url});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.grey.shade700,
      backgroundImage: url != null ? CachedNetworkImageProvider(url!) : null,
    );
  }
}
