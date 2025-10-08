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
      orElse: () => const ReactionOption(
        type: ReactionType.like,
        emoji: '👍',
        color: Colors.orange,
      ),
    );
    return match.emoji;
  }

  @override
  Widget build(BuildContext context) {
    return Stack( // ✅ Dùng Stack để popup nổi lên trên các phần khác
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onLongPressStart: (_) {
                      // ✅ Thay vì onLongPress (thời gian mặc định ~1s),
                      // ta dùng onLongPressStart và set timer để hiển thị nhanh hơn
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (mounted) {
                          setState(() => _showReactions = true);
                        }
                      });
                    },
                    onLongPressEnd: (_) {
                      // Nếu người dùng nhả sớm thì không hiển thị popup
                      if (mounted && _showReactions) {
                        setState(() => _showReactions = false);
                      }
                    },
                    onTap: () {
                      setState(() {
                        _selectedReaction = _selectedReaction == null
                            ? ReactionType.like
                            : null;
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
            ),
          ],
        ),

        // ✅ Hiển thị popup nổi lên trên nút like
        if (_showReactions)
          Positioned(
            bottom: 33,
            left: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              child: ReactionPopup(
                key: const ValueKey('popup'),
                onSelect: (reaction) {
                  setState(() {
                    _selectedReaction = reaction;
                    _showReactions = false;
                  });
                },
              ),
            ),
          ),
      ],
    );
  }
}
