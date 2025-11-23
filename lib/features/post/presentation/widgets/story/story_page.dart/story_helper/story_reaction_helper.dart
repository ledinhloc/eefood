import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:eefood/features/post/presentation/widgets/post/reaction_popup.dart';
import 'package:flutter/material.dart';

/// Helper class quản lý reaction popup
class StoryReactionHelper {
  OverlayEntry? _reactionPopup;
  final VoidCallback onPause;
  final VoidCallback onResume;

  StoryReactionHelper({required this.onPause, required this.onResume});

  void showReactionPopup(
    BuildContext context,
    Offset position,
    Function(ReactionType) onReactionSelected,
  ) {
    hidePopup();

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    _reactionPopup = OverlayEntry(
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          hidePopup();
          onResume();
        },
        child: Stack(
          children: [
            Positioned(
              left: position.dx - 10,
              top: position.dy - 80,
              child: Material(
                color: Colors.transparent,
                child: ReactionPopup(
                  onSelect: (reaction) {
                    onReactionSelected(reaction);
                    hidePopup();
                    onResume();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(_reactionPopup!);
    onPause();
  }

  void hidePopup() {
    _reactionPopup?.remove();
    _reactionPopup = null;
  }

  void dispose() {
    hidePopup();
  }
}
