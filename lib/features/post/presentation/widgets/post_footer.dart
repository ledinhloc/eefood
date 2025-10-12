import 'package:eefood/features/post/presentation/provider/post_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/post_model.dart';
import '../../data/models/reaction_type.dart';
import 'reaction_popup.dart';
import 'footer_button.dart';

class PostFooter extends StatefulWidget {
  final PostModel post;
  final void Function(Offset offset, Function(ReactionType) onSelect)? onShowReactions;
  const PostFooter({super.key, required this.post, this.onShowReactions});

  @override
  State<PostFooter> createState() => _PostFooterState();
}

class _PostFooterState extends State<PostFooter> with SingleTickerProviderStateMixin{
  ReactionType? _selectedReaction;
  @override
  void initState() {
    super.initState();
  }

  IconData _getReactionIcon(ReactionType? type){
    if(type ==  null) return Icons.thumb_up_alt_outlined;
    final match = reactions.firstWhere(
        (r) => r.type == type,
      orElse: () => reactions.first,
    );
    return match.icon;
  }
  @override
  void dispose() {
    super.dispose();
  }

  void _handleReact(ReactionType? newReaction) async{
    final cubit = context.read<PostListCubit>();

    if(_selectedReaction == newReaction || newReaction == null){
      //neu chon lai cung loai
      await cubit.removeReaction(widget.post.id);
      setState(() {
        _selectedReaction = null;
      });
    }else{
      await cubit.reactToPost(widget.post.id, newReaction);
      setState(() {
        _selectedReaction = newReaction;
      });
    }
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
                _selectedReaction == null ? ReactionType.LIKE : null
              );
            },
            child: FooterButton(
              icon: _getReactionIcon(_selectedReaction),
              label: '',
            ),
          ),
          const FooterButton(icon: Icons.mode_comment_outlined, label: 'Comment'),
          const FooterButton(icon: Icons.share_outlined, label: 'Share'),
        ],
      ),
    );
  }
}
