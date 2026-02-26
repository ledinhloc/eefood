import 'package:flutter/material.dart';

class DotsLoadingIndicator extends StatefulWidget {
  final Color color;
  final double dotSize;

  const DotsLoadingIndicator({
    super.key,
    this.color = const Color(0xFFFF6B35),
    this.dotSize = 7,
  });

  @override
  State<DotsLoadingIndicator> createState() => _DotsLoadingIndicatorState();
}

class _DotsLoadingIndicatorState extends State<DotsLoadingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  static const _dotCount = 3;
  static const _delayMs = 150;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _dotCount,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _animations = _controllers.map((c) {
      return Tween<double>(
        begin: 0,
        end: -6,
      ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut));
    }).toList();

    // Start each dot with a staggered delay
    for (int i = 0; i < _dotCount; i++) {
      Future.delayed(Duration(milliseconds: i * _delayMs), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_dotCount, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (_, __) => Transform.translate(
            offset: Offset(0, _animations[i].value),
            child: Container(
              width: widget.dotSize,
              height: widget.dotSize,
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}
