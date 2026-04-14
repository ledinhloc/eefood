import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class NutritionDayPoint {
  final DateTime date;
  final double value;
  final bool isSelected;
  final String weekday;
  final String dayLabel;

  const NutritionDayPoint({
    required this.date,
    required this.value,
    required this.isSelected,
    required this.weekday,
    required this.dayLabel,
  });
}
//vẽ
// lưới
// đường cong
// nền tô
// chấm
// số value phía trên chấm
class NutritionTrendPainter extends CustomPainter {
  final List<NutritionDayPoint> points;
  final Color lineColor;
  final Color axisColor;
  final Color textColor;
  final double maxValue;

  const NutritionTrendPainter({
    required this.points,
    required this.lineColor,
    required this.axisColor,
    required this.textColor,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const topPadding = 10.0;
    const bottomPadding = 14.0;
    final usableHeight = size.height - topPadding - bottomPadding;
    final spacing = points.length == 1 ? 0.0 : size.width / (points.length - 1);
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;

    final gridPaint = Paint()
      ..color = axisColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Vẽ các đường lưới ngang làm nền cho biểu đồ.
    for (var i = 0; i < 4; i++) {
      final y = topPadding + (usableHeight * i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final chartOffsets = <Offset>[];
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final ratio = point.value / safeMax;
      final x = spacing * i;
      final y = topPadding + usableHeight - (ratio * usableHeight);
      chartOffsets.add(Offset(x, y));
    }

    // Nối các điểm dữ liệu bằng đường cong để chart nhìn mềm hơn.
    final linePath = Path()..moveTo(chartOffsets.first.dx, chartOffsets.first.dy);
    for (var i = 1; i < chartOffsets.length; i++) {
      final previous = chartOffsets[i - 1];
      final current = chartOffsets[i];
      final controlX = (previous.dx + current.dx) / 2;
      linePath.cubicTo(
        controlX,
        previous.dy,
        controlX,
        current.dy,
        current.dx,
        current.dy,
      );
    }

    final fillPath = Path.from(linePath)
      ..lineTo(chartOffsets.last.dx, size.height)
      ..lineTo(chartOffsets.first.dx, size.height)
      ..close();

    // Tô nền gradient phía dưới đường biểu diễn.
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.22),
          lineColor.withValues(alpha: 0.02),
        ],
      ).createShader(Offset.zero & size);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    for (var i = 0; i < chartOffsets.length; i++) {
      final point = points[i];
      final offset = chartOffsets[i];

      if (point.isSelected) {
        // Vẽ vạch dọc để làm nổi bật ngày đang được chọn.
        final markerPaint = Paint()
          ..color = lineColor.withValues(alpha: 0.12)
          ..strokeWidth = 2;
        canvas.drawLine(
          Offset(offset.dx, topPadding),
          Offset(offset.dx, size.height),
          markerPaint,
        );
      }

      final dotPaint = Paint()
        ..color = point.isSelected ? lineColor : Colors.white;
      final dotBorderPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = point.isSelected ? 3 : 2;

      // Vẽ chấm dữ liệu và hiển thị giá trị ngay phía trên chấm đó.
      canvas.drawCircle(offset, point.isSelected ? 6 : 4.5, dotPaint);
      canvas.drawCircle(offset, point.isSelected ? 6 : 4.5, dotBorderPaint);

      final valueText = TextPainter(
        text: TextSpan(
          text: point.value % 1 == 0
              ? point.value.toInt().toString()
              : point.value.toStringAsFixed(1),
          style: TextStyle(
            color: point.isSelected ? lineColor : textColor,
            fontSize: 10,
            fontWeight: point.isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();

      valueText.paint(
        canvas,
        Offset(
          offset.dx - (valueText.width / 2),
          math.max(0, offset.dy - valueText.height - 10),
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant NutritionTrendPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.axisColor != axisColor ||
        oldDelegate.textColor != textColor ||
        oldDelegate.maxValue != maxValue;
  }
}
