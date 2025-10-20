import 'package:flutter/material.dart';

class ReactionAnimation extends StatefulWidget {
  final String emoji;
  final Offset startPosition;

  const ReactionAnimation({
    super.key,
    required this.emoji,
    required this.startPosition,
  });

  @override
  State<ReactionAnimation> createState() => _ReactionAnimationState();
}

class _ReactionAnimationState extends State<ReactionAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _moveUp;
  late final Animation<double> _fadeOut;
  late final Animation<double> _scaleUp;
  late final Animation<double> _wiggle;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _moveUp = Tween<double>(begin: 0, end: -150).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeOut = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0)),
    );

    _scaleUp = Tween<double>(begin: 0.9, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // Thêm nhẹ hiệu ứng lắc ngang (như Facebook)
    _wiggle = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.startPosition.dx,
      top: widget.startPosition.dy,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          return Transform.translate(
            offset: Offset(_wiggle.value, _moveUp.value),
            child: Transform.scale(
              scale: _scaleUp.value,
              child: Opacity(
                opacity: _fadeOut.value,
                child: Text(
                  widget.emoji,
                  style: const TextStyle(
                    fontSize: 28,
                    height: 1,
                    color: Colors.black,
                    shadows: [], // bỏ shadow tránh vệt vàng
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
