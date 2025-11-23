import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/number_formatter.dart';
import 'package:eefood/core/utils/reaction_helper.dart';
import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:eefood/features/post/presentation/provider/story_comment_cubit.dart';
import 'package:eefood/features/post/presentation/provider/story_reaction_cubit.dart';
import 'package:eefood/features/post/presentation/provider/story_reaction_list_cubit.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_page.dart/story_comment/story_comment_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoryActionBar extends StatefulWidget {
  final Function(ReactionType) onReact;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final Function(Offset position)? onOpenReactionPopup;
  final int? storyId;
  final int? currentUserId;

  const StoryActionBar({
    super.key,
    required this.onReact,
    required this.onPause,
    required this.onResume,
    this.onOpenReactionPopup,
    this.storyId,
    this.currentUserId,
  });

  @override
  State<StoryActionBar> createState() => _StoryActionBarState();
}

class _StoryActionBarState extends State<StoryActionBar> {
  final GlobalKey _reactKey = GlobalKey();

  void _showPopup() {
    widget.onPause();
    final renderBox =
        _reactKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      widget.onResume();
      return;
    }

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final adjustedPosition = Offset(
      position.dx - 150,
      position.dy + size.height / 2 - 20,
    );

    widget.onOpenReactionPopup?.call(adjustedPosition);
  }

  void _showCommentBottomSheet() {
    widget.onPause();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final commentCubit = getIt<StoryCommentCubit>();

        if (widget.storyId != null) {
          commentCubit.loadComments(widget.storyId!);
        }

        return BlocProvider.value(
          value: commentCubit,
          child: DraggableScrollableSheet(
            initialChildSize: 0.88,
            maxChildSize: 0.95,
            minChildSize: 0.4,
            expand: false,
            builder: (context, scrollController) {
              return StoryCommentBottomSheet(
                storyId: widget.storyId,
                currentUserId: widget.currentUserId,
              );
            },
          ),
        );
      },
    ).whenComplete(() {
      widget.onResume();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryReactionCubit, StoryReactionState>(
      builder: (context, reactionState) {
        final currentReaction =
            reactionState.reaction?.reactionType ?? ReactionType.LOVE;
        final hasReacted = reactionState.reaction != null;

        return BlocBuilder<StoryReactionStatsCubit, StoryReactionStatsState>(
          builder: (context, statsState) {
            return BlocBuilder<StoryCommentCubit, StoryCommentState>(
              builder: (context, commentState) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Like Button
                      GestureDetector(
                        key: _reactKey,
                        onTap: () {
                          widget.onPause();
                          widget.onReact(currentReaction);
                          widget.onResume();
                        },
                        onLongPressStart: (_) {
                          _showPopup();
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: hasReacted
                                    ? Colors.red.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: reactionState.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : hasReacted
                                  ? Text(
                                      ReactionHelper.emoji(currentReaction),
                                      style: const TextStyle(fontSize: 24),
                                    )
                                  : const Icon(
                                      Icons.favorite_border,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              statsState.totalReactions > 0
                                  ? formatCompactNumber(
                                      statsState.totalReactions,
                                    )
                                  : '0',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Comment Button
                      GestureDetector(
                        onTap: _showCommentBottomSheet,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              commentState.totalElements > 0
                                  ? formatCompactNumber(
                                      commentState.totalElements,
                                    )
                                  : '0',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
