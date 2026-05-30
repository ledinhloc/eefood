import 'package:flutter/material.dart';

class ShimmerOverlay extends StatelessWidget {
  final AnimationController ctrl;
  const ShimmerOverlay({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: ctrl,
        builder: (_, __) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CustomPaint(
              painter: _ShimmerPainter(progress: ctrl.value),
            ),
          );
        },
      ),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  final double progress;

  const _ShimmerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final shimmerX = -size.width + progress * size.width * 3;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final shimmerRect = Rect.fromLTWH(
      shimmerX - size.width * 0.3,
      0,
      size.width * 0.6,
      size.height,
    );

    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Colors.transparent,
          Color(0x14FFFFFF), // white 8%
          Colors.transparent,
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(shimmerRect);

    canvas.clipRect(rect);
    canvas.drawRect(shimmerRect, paint);
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) => old.progress != progress;
}