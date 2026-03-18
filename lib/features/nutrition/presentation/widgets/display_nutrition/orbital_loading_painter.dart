import 'dart:math';

import 'package:flutter/material.dart';

class OrbitalLoadingPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  const OrbitalLoadingPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Outer ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFFFF6B00).withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Arc sweep
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      progress * 2 * pi - pi / 2,
      pi * 1.2,
      false,
      Paint()
        ..color = const Color(0xFFFF6B00)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Orbiting dot (glow)
    final angle = progress * 2 * pi - pi / 2;
    final dotOffset = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );
    canvas.drawCircle(
      dotOffset,
      6,
      Paint()
        ..color = const Color(0xFFFF6B00)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(dotOffset, 4, Paint()..color = const Color(0xFFFF9A3C));

    // Inner pulse circle
    canvas.drawCircle(
      center,
      24 + 6 * sin(progress * 2 * pi),
      Paint()
        ..color = const Color(0xFFFF6B00).withOpacity(0.1)
        ..style = PaintingStyle.fill,
    );

    // Center oval icon
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 18, height: 24),
      Paint()
        ..color = const Color(0xFFFF6B00)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(OrbitalLoadingPainter old) => old.progress != progress;
}
