import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/share_utils.dart';
import 'package:eefood/features/post/presentation/provider/comment_list_cubit.dart';
import 'package:eefood/features/post/presentation/provider/post_list_cubit.dart';
import 'package:eefood/features/post/presentation/widgets/comment/comment_sheet.dart';
import 'package:eefood/features/post/presentation/widgets/share/share_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/reaction_type.dart';
import 'footer_button.dart';

class PostFooter extends StatefulWidget {
  final PostModel post;
  final void Function(Offset offset, Function(ReactionType) onSelect)?
  onShowReactions;
  const PostFooter({super.key, required this.post, this.onShowReactions});

  @override
  State<PostFooter> createState() => _PostFooterState();
}

class _PostFooterState extends State<PostFooter>
    with SingleTickerProviderStateMixin {
  ReactionType? _selectedReaction;
  @override
  void initState() {
    super.initState();
  }

  String _getReactionEmoji(ReactionType? type) {
    if (type == null) return '👍🏻';
    final match = reactions.firstWhere(
      (r) => r.type == type,
      orElse: () => const ReactionOption(
        type: ReactionType.LIKE,
        emoji: '👍',
        color: Colors.orange,
      ),
    );
    return match.emoji;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleReact(ReactionType? newReaction) async {
    final cubit = context.read<PostListCubit>();

    if (_selectedReaction == newReaction || newReaction == null) {
      //neu chon lai cung loai
      await cubit.removeReaction(widget.post.id);
      setState(() {
        _selectedReaction = null;
      });
    } else {
      await cubit.reactToPost(widget.post.id, newReaction);
      setState(() {
        _selectedReaction = newReaction;
      });
    }
  }

  void _openCommentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlocProvider(
          create: (_) =>
              getIt<CommentListCubit>()..fetchComments(widget.post.id),
          child: CommentBottomSheet(postId: widget.post.id),
        );
      },
    );
  }

  void _openShareSheet() {
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareBottomSheet(
        postId: widget.post.recipeId!,
        imageUrl: widget.post.imageUrl,
        contentPreview: widget.post.title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onLongPressStart: (details) {
              widget.onShowReactions?.call(details.globalPosition, (reaction) {
                _handleReact(reaction);
              });
            },
            onTap: () {
              _handleReact(
                _selectedReaction == null ? ReactionType.LIKE : null,
              );
            },
            child: FooterButton(
              icon: _getReactionEmoji(_selectedReaction),
              label: '',
            ),
          ),
          FooterButton(
            icon: '💬',
            label: 'Comment',
            onPressed: _openCommentSheet,
          ),
          FooterButton(icon: '🔗', label: 'Share', onPressed: _openShareSheet),
        ],
      ),
    );
  }
}
