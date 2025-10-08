import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import 'reaction_popup.dart';
import 'footer_button.dart';

class PostFooter extends StatefulWidget {
  final PostModel post;
  const PostFooter({super.key, required this.post});

  @override
  State<PostFooter> createState() => _PostFooterState();
}

class _PostFooterState extends State<PostFooter> {
  bool _showReactions = false;
  ReactionType? _selectedReaction;

  String _getReactionEmoji(ReactionType? type) {
    if (type == null) return '👍🏻';
    final match = ReactionPopup.reactions.firstWhere(
          (r) => r.type == type,
      orElse: () => const ReactionOption(type: ReactionType.like, emoji: '👍', color: Colors.orange),
    );
    return match.emoji;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _showReactions
              ? ReactionPopup(
            key: const ValueKey('popup'),
            onSelect: (reaction) {
              setState(() {
                _selectedReaction = reaction;
                _showReactions = false;
              });
            },
          )
              : const SizedBox.shrink(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onLongPress: () => setState(() => _showReactions = true),
                onTap: () {
                  setState(() {
                    _selectedReaction = _selectedReaction == null
                        ? ReactionType.like
                        : null;
                  });
                },
                child: FooterButton(icon: _getReactionEmoji(_selectedReaction), label: '',),
              ),
              const FooterButton(icon: '💬', label: 'Comment'),
              const FooterButton(icon: '🔗', label: 'Share'),
            ],
          ),
        ),
      ],
    );
  }
}
