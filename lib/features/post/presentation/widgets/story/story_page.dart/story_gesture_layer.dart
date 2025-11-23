import 'package:flutter/material.dart';

class StoryGestureLayer extends StatelessWidget {
  final Widget child;
  final VoidCallback onTapLeft;
  final VoidCallback onTapRight;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;

  const StoryGestureLayer({
    super.key,
    required this.child,
    required this.onTapLeft,
    required this.onTapRight,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    this.onLongPressStart,
    this.onLongPressEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (_) => onLongPressStart?.call(),
      onLongPressEnd: (_) => onLongPressEnd?.call(),
      onTapUp: (d) {
        final w = MediaQuery.of(context).size.width;
        d.globalPosition.dx < w * 0.3 ? onTapLeft() : onTapRight();
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          details.primaryVelocity! < 0 ? onSwipeLeft() : onSwipeRight();
        }
      },
      child: child,
    );
  }
}
