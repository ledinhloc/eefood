import 'package:flutter/material.dart';
import 'dart:math' as math;

class ScoreGaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  ScoreGaugePainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 6;
    const startAngle = -math.pi * 0.8;
    const sweepAngle = math.pi * 1.6;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(ScoreGaugePainter old) =>
      old.progress != progress || old.color != color;
}
