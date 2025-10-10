import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import 'reaction_popup.dart';
import 'footer_button.dart';

class PostFooter extends StatefulWidget {
  final PostModel post;
  static final List<_PostFooterState> _activeFooters = [];
  static void closeAllPopups() {
    for (final footer in List<_PostFooterState>.from(_activeFooters)) {
      footer._removePopup();
    }
  }
  const PostFooter({super.key, required this.post});

  @override
  State<PostFooter> createState() => _PostFooterState();
}

class _PostFooterState extends State<PostFooter> {
  ReactionType? _selectedReaction;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    PostFooter._activeFooters.add(this);
  }

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

  // ✅ Hiển thị popup (với vùng click ra ngoài)
  void _showReactionsPopup(BuildContext context, Offset offset) {
    _removePopup(); // xóa popup cũ nếu có

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _removePopup, // 👈 nhấn ra ngoài để tắt popup
        onPanStart: (_) => _removePopup(), // 👈 khi người dùng kéo
        child: Stack(
          children: [
            Positioned(
              left: offset.dx - 40,
              top: offset.dy - 80,
              child: Material(
                color: Colors.transparent,
                child: ReactionPopup(
                  onSelect: (reaction) {
                    setState(() => _selectedReaction = reaction);
                    _removePopup();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removePopup() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    PostFooter._activeFooters.remove(this);
    _removePopup();
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
              final position = details.globalPosition;
              _showReactionsPopup(context, position);
            },
            onTap: () {
              setState(() {
                _selectedReaction =
                _selectedReaction == null ? ReactionType.like : null;
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
