import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/reaction_helper.dart';
import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:eefood/features/post/presentation/provider/comment_reaction_cubit.dart';
import 'package:eefood/features/post/presentation/widgets/comment/comment_reaction/comment_reaction_summary.dart';
import 'package:flutter/material.dart';
import 'package:eefood/core/utils/convert_time.dart';
import 'package:eefood/features/post/data/models/comment_model.dart';
import 'package:eefood/features/post/presentation/provider/comment_list_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentItemActions extends StatelessWidget {
  final CommentModel comment;
  final int depth;
  final GlobalKey actionButtonKey;
  final CommentListCubit cubit;
  final Function(BuildContext) showReactionPopup;

  const CommentItemActions({
    super.key,
    required this.comment,
    required this.depth,
    required this.actionButtonKey,
    required this.cubit,
    required this.showReactionPopup,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserReaction = comment.currentUserReaction;
    final hasCurrentReaction = currentUserReaction != null;
    print('CurrentReact $hasCurrentReaction');
    print('CommentItemActions => commentId=${comment.id}');
    return Row(
      children: [
        Text(
          TimeParser.formatCommentTime(comment.createdAt),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          key: actionButtonKey,
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onTap: () => showReactionPopup(context),
          child: Row(
            children: [
              Text(
                hasCurrentReaction
                    ? ReactionHelper.label(currentUserReaction!)
                    : "Thích",
                style: TextStyle(
                  fontSize: 12,
                  color: hasCurrentReaction
                      ? ReactionHelper.color(currentUserReaction!)
                      : Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        if (depth < 3)
          GestureDetector(
            onTap: () => cubit.setReplyingTo(comment),
            child: Text(
              "Trả lời",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        const SizedBox(width: 5),
        if (comment.reactionCounts != null &&
            comment.reactionCounts!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: BlocProvider(
              create: (_) =>
                  getIt<CommentReactionCubit>()..fetchReactions(comment.id!),
              child: CommentReactionSummary(
                commentId: comment.id!,
                reactionCounts: comment.reactionCounts!,
              ),
            ),
          ),
      ],
    );
  }
}
