import 'package:eefood/core/utils/reaction_helper.dart';
import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:eefood/features/post/presentation/provider/comment_reaction_cubit.dart';
import 'package:eefood/features/post/presentation/widgets/comment/comment_reaction/comment_react_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentReactionSummary extends StatelessWidget {
  final int commentId;
  final Map<ReactionType, int> reactionCounts;

  const CommentReactionSummary({
    super.key,
    required this.commentId,
    required this.reactionCounts,
  });

  @override
  Widget build(BuildContext context) {
    print(
      'Building CommentReactionSummary for commentId=$commentId with ${reactionCounts.length} reactions',
    );

    final filteredReactions = reactionCounts.entries
        .where((entry) => entry.value > 0)
        .toList();

    if (filteredReactions.isEmpty) {
      return const SizedBox.shrink();
    }

    filteredReactions.sort((a, b) => b.value.compareTo(a.value));
    final topReactions = filteredReactions.take(3).toList();
    final totalCount = filteredReactions.fold<int>(
      0,
      (sum, e) => sum + e.value,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          print('Tapped CommentReactionSummary → commentId=$commentId');
          _showReactionBottomSheet(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...topReactions.asMap().entries.map((entry) {
                final index = entry.key;
                final emoji = ReactionHelper.emoji(entry.value.key);
                return Container(
                  margin: EdgeInsets.only(left: index * 8.0),
                  child: Text(emoji, style: const TextStyle(fontSize: 14)),
                );
              }),
              const SizedBox(width: 4),
              Text(
                totalCount.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReactionBottomSheet(BuildContext context) {
    final cubit = context.read<CommentReactionCubit>();

    cubit.fetchReactions(commentId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return BlocProvider.value(
          value: cubit,
          child: CommentReactListPage(
            commentId: commentId,
            reactionCounts: reactionCounts,
          ),
        );
      },
    );
  }
}
