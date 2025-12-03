import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eefood/core/utils/reaction_helper.dart';
import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:eefood/features/post/data/models/story_reaction_model.dart';
import 'package:eefood/features/post/presentation/provider/story_reaction_list_cubit.dart';
import 'package:eefood/features/post/presentation/provider/story_viewer_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoryViewerBar extends StatelessWidget {
  final VoidCallback onOpenList;

  const StoryViewerBar({super.key, required this.onOpenList});

  ReactionType? _getReactionForUser(
    int userId,
    List<StoryReactionModel> reactions,
  ) {
    try {
      final reaction = reactions.firstWhere((r) => r.userId == userId);
      return reaction.reactionType;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryViewerCubit, StoryViewerState>(
      builder: (context, viewerState) {
        return BlocBuilder<StoryReactionStatsCubit, StoryReactionStatsState>(
          builder: (context, reactionState) {
            final total = viewerState.totalElements ?? 0;
            final viewers = viewerState.viewers;
            final reactions = reactionState.reactions;

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
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
                                  final reaction = v.userId != null
                                      ? _getReactionForUser(
                                          v.userId!,
                                          reactions,
                                        )
                                      : null;
                                  return Positioned(
                                    key: ValueKey(v.id),
                                    left: i * 30,
                                    child: ViewerAvatar(
                                      url: v.avatarUrl,
                                      reaction: reaction,
                                    ),
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
          },
        );
      },
    );
  }
}

class ViewerAvatar extends StatelessWidget {
  final String? url;
  final ReactionType? reaction;
  const ViewerAvatar({super.key, this.url, this.reaction});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey.shade700,
          backgroundImage: url != null
              ? CachedNetworkImageProvider(url!)
              : null,
        ),

        // Reaction emoji badge
        if (reaction != null)
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Text(
                ReactionHelper.emoji(reaction!),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }
}
