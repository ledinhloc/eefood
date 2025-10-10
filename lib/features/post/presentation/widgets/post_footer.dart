import 'package:flutter/material.dart';
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

class _PostFooterState extends State<PostFooter> {
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
                setState(() => _selectedReaction = reaction);
              });
            },
            onTap: () {
              setState(() {
                _selectedReaction =
                _selectedReaction == null ? ReactionType.LIKE : null;
              });
            },
            child: FooterButton(
              icon: _getReactionEmoji(_selectedReaction),
              label: '',
            ),
          ),
          const FooterButton(icon: '💬', label: 'Comment'),
          const FooterButton(icon: '🔗', label: 'Share'),
        ],
      ),
    );
  }
}
