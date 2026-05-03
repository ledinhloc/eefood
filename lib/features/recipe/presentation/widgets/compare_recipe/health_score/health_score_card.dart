import 'package:flutter/material.dart';
import 'dart:math' as math;

class HealthScoreCard extends StatelessWidget {
  final String label;
  final double score;
  final double maxScore;
  final Color color;
  final double progress;
  const HealthScoreCard({
    super.key,
    required this.label,
    required this.score,
    required this.maxScore,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final displayScore = (score * progress).clamp(0.0, 100.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CustomPaint(
              painter: _ArcPainter(
                progress: progress,
                score: score / maxScore,
                color: color,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      displayScore.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: color,
                        height: 1,
                      ),
                    ),
                    Text(
                      '/ $maxScore',
                      style: TextStyle(
                        fontSize: 9,
                        color: color.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getHealthLabel(score),
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getHealthLabel(double score) {
    if (score == 0) return 'Chưa có';
    if (score >= 80) return '🌟 Rất tốt';
    if (score >= 60) return '✅ Tốt';
    if (score >= 40) return '⚠️ Trung bình';
    return '❌ Kém';
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final double score;
  final Color color;

  _ArcPainter({
    required this.progress,
    required this.score,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Background arc
    final bgPaint = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Foreground arc
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * score * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
