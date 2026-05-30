import 'package:flutter/material.dart';
import 'dart:math' as math;

class ParticlePainter extends CustomPainter {
  final double progress;
  static const int _count = 8;
  static const double _maxRadius = 28;

  const ParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFFE040FB),
      const Color(0xFF7C6AFF),
      const Color(0xFFFF6B9D),
      const Color(0xFF00E5FF),
      const Color(0xFFFFB86C),
      const Color(0xFF69FF47),
      const Color(0xFFFF79C6),
    ];

    for (int i = 0; i < _count; i++) {
      final angle = (2 * math.pi / _count) * i - math.pi / 2;
      final distance = _maxRadius * progress;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final radius = (3.5 * (1 - progress * 0.6)).clamp(0.5, 4.0);

      final x = center.dx + distance * math.cos(angle);
      final y = center.dy + distance * math.sin(angle);

      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter old) => old.progress != progress;
}
