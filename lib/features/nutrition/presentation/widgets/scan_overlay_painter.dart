import 'dart:io';

import 'package:flutter/material.dart';

class ScanOverlayPainter extends CustomPainter {
  final double boxSize;
  final double borderRadius;
  final double glowOpacity;
  final double scanLineY;
  final File? capturedImage;

  ScanOverlayPainter({
    required this.boxSize,
    required this.borderRadius,
    required this.glowOpacity,
    required this.scanLineY,
    this.capturedImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: boxSize,
      height: boxSize,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Dark overlay outside box
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.55);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, overlayPaint);

    // Glow border
    final glowPaint = Paint()
      ..color = const Color(0xFFFF6B00).withOpacity(glowOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(rrect, glowPaint);

    // Solid border
    final borderPaint = Paint()
      ..color = const Color(0xFFFF6B00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(rrect, borderPaint);

    // Corner accents
    _drawCorners(canvas, rect, borderRadius);

    // Scan line
    if (capturedImage == null) {
      final lineY = rect.top + scanLineY * boxSize;
      final linePaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFFFF6B00).withOpacity(0.9),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(rect.left, lineY, boxSize, 2));
      canvas.save();
      canvas.clipRRect(rrect);
      canvas.drawLine(
        Offset(rect.left, lineY),
        Offset(rect.right, lineY),
        linePaint..strokeWidth = 2,
      );
      canvas.restore();
    }
  }

  void _drawCorners(Canvas canvas, Rect rect, double r) {
    final paint = Paint()
      ..color = const Color(0xFFFF6B00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const len = 24.0;

    // Top-left
    canvas.drawLine(
      Offset(rect.left + r, rect.top),
      Offset(rect.left + r + len, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top + r),
      Offset(rect.left, rect.top + r + len),
      paint,
    );
    // Top-right
    canvas.drawLine(
      Offset(rect.right - r - len, rect.top),
      Offset(rect.right - r, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top + r),
      Offset(rect.right, rect.top + r + len),
      paint,
    );
    // Bottom-left
    canvas.drawLine(
      Offset(rect.left + r, rect.bottom),
      Offset(rect.left + r + len, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom - r - len),
      Offset(rect.left, rect.bottom - r),
      paint,
    );
    // Bottom-right
    canvas.drawLine(
      Offset(rect.right - r - len, rect.bottom),
      Offset(rect.right - r, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom - r - len),
      Offset(rect.right, rect.bottom - r),
      paint,
    );
  }

  @override
  bool shouldRepaint(ScanOverlayPainter old) =>
      old.glowOpacity != glowOpacity || old.scanLineY != scanLineY;
}