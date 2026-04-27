import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:eefood/features/profile/presentation/widgets/metrics_page/body_metric_chart_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MetricChartPainter<T> extends CustomPainter {
  final List<BodyMetricChartPoint<T>> points;
  final List<BmiZone> zones;
  final Color lineColor;
  final Color textColor;
  final Color axisColor;
  final double minY;
  final double maxY;
  final String unit;
  final String Function(double) formatValue;
  final bool isDark;
  final bool showPointLabels;

  const MetricChartPainter({
    required this.points,
    required this.zones,
    required this.lineColor,
    required this.textColor,
    required this.axisColor,
    required this.minY,
    required this.maxY,
    required this.unit,
    required this.formatValue,
    required this.isDark,
    required this.showPointLabels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padding = ChartPadding();
    // Painter chỉ vẽ trong vùng này; phần padding dành cho nhãn xung quanh.
    final chartRect = Rect.fromLTWH(
      padding.left,
      padding.top,
      size.width - padding.left - padding.right,
      size.height - padding.top - padding.bottom,
    );

    _drawZones(canvas, chartRect);
    _drawGrid(canvas, chartRect);
    _drawLine(canvas, chartRect);
    if (showPointLabels) {
      _drawPointLabels(canvas, chartRect);
    }
    _drawLabels(canvas, chartRect);
  }

  void _drawZones(Canvas canvas, Rect chartRect) {
    if (zones.isEmpty) return;
    for (final zone in zones) {
      final top = _yForValue(zone.max, chartRect);
      final bottom = _yForValue(zone.min, chartRect);
      final rect = Rect.fromLTRB(chartRect.left, top, chartRect.right, bottom);
      final radius = Radius.circular(
        zone == zones.first || zone == zones.last ? 14 : 0,
      );
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: zone == zones.last ? radius : Radius.zero,
          topRight: zone == zones.last ? radius : Radius.zero,
          bottomLeft: zone == zones.first ? radius : Radius.zero,
          bottomRight: zone == zones.first ? radius : Radius.zero,
        ),
        Paint()..color = zone.color,
      );

      final centerY = (top + bottom) / 2;
      _paintPillText(
        canvas,
        zone.label,
        Offset(chartRect.left + 8, centerY),
        zone.color,
      );
    }
  }

  void _drawGrid(Canvas canvas, Rect chartRect) {
    final gridPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 1;

    if (zones.isNotEmpty) {
      final boundaries = <double>{minY, maxY};
      for (final zone in zones) {
        boundaries
          ..add(zone.min)
          ..add(zone.max);
      }
      for (final value in boundaries) {
        final y = _yForValue(value, chartRect);
        canvas.drawLine(
          Offset(chartRect.left, y),
          Offset(chartRect.right, y),
          gridPaint,
        );
      }
      return;
    }

    for (var i = 0; i <= 3; i++) {
      final y = chartRect.top + chartRect.height * i / 3;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        gridPaint,
      );
    }
  }

  void _drawLine(Canvas canvas, Rect chartRect) {
    if (points.isEmpty) return;
    final offsets = <Offset>[];
    // Tính tọa độ điểm một lần, rồi dùng lại cho đường, nền và chấm.
    for (var i = 0; i < points.length; i++) {
      final x =
          chartRect.left +
          chartXForPointIndex(points: points, index: i, width: chartRect.width);
      final y = _yForValue(points[i].value, chartRect);
      offsets.add(Offset(x, y));
    }

    if (offsets.length > 1) {
      final path = _smoothPath(offsets);
      // Tô vùng dưới đường bằng hiệu ứng mờ dần nhẹ.
      final fillPath = Path.from(path)
        ..lineTo(offsets.last.dx, chartRect.bottom)
        ..lineTo(offsets.first.dx, chartRect.bottom)
        ..close();
      final fillPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, chartRect.top),
          Offset(0, chartRect.bottom),
          [
            lineColor.withValues(alpha: isDark ? 0.24 : 0.18),
            lineColor.withValues(alpha: 0.02),
          ],
        );
      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(
        path,
        Paint()
          ..color = lineColor
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    for (final offset in offsets) {
      canvas.drawCircle(
        offset,
        7,
        Paint()..color = Colors.white.withValues(alpha: isDark ? 0.92 : 1),
      );
      canvas.drawCircle(offset, 4.5, Paint()..color = lineColor);
    }
  }

  Path _smoothPath(List<Offset> offsets) {
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (var i = 0; i < offsets.length - 1; i++) {
      final current = offsets[i];
      final next = offsets[i + 1];
      final controlX = (current.dx + next.dx) / 2;
      path.cubicTo(controlX, current.dy, controlX, next.dy, next.dx, next.dy);
    }
    return path;
  }

  void _drawPointLabels(Canvas canvas, Rect chartRect) {
    for (var i = 0; i < points.length; i++) {
      final x =
          chartRect.left +
          chartXForPointIndex(points: points, index: i, width: chartRect.width);
      final y = _yForValue(points[i].value, chartRect);
      _paintValueBubble(
        canvas,
        formatValue(points[i].value),
        Offset(x, math.max(chartRect.top + 12, y - 24)),
        chartRect.left,
        chartRect.right,
      );
    }
  }

  void _drawLabels(Canvas canvas, Rect chartRect) {
    if (zones.isNotEmpty) {
      final boundaries = <double>{};
      for (final zone in zones) {
        boundaries
          ..add(zone.min)
          ..add(zone.max);
      }
      final sortedBoundaries = boundaries.toList()..sort();
      for (final value in sortedBoundaries) {
        final y = _yForValue(value, chartRect);
        _paintText(
          canvas,
          formatValue(value),
          Offset(2, (y - 6).clamp(chartRect.top - 2, chartRect.bottom - 10)),
          9.5,
          textColor.withValues(alpha: 0.78),
          FontWeight.w700,
        );
      }
      _drawDateLabels(canvas, chartRect);
      return;
    }

    final topValue = unit.isEmpty
        ? formatValue(maxY)
        : '${formatValue(maxY)} $unit';
    final bottomValue = unit.isEmpty
        ? formatValue(minY)
        : '${formatValue(minY)} $unit';
    _paintText(
      canvas,
      topValue,
      Offset(0, chartRect.top - 2),
      10,
      textColor,
      FontWeight.w600,
    );
    _paintText(
      canvas,
      bottomValue,
      Offset(0, chartRect.bottom - 12),
      10,
      textColor,
      FontWeight.w600,
    );

    _drawDateLabels(canvas, chartRect);
  }

  void _drawDateLabels(Canvas canvas, Rect chartRect) {
    if (points.isEmpty) return;
    final dateFormat = DateFormat('dd/MM');
    final tickPaint = Paint()
      ..color = axisColor.withValues(alpha: 0.9)
      ..strokeWidth = 1;

    for (var i = 0; i < points.length; i++) {
      final x =
          chartRect.left +
          chartXForPointIndex(points: points, index: i, width: chartRect.width);
      canvas.drawLine(
        Offset(x, chartRect.bottom),
        Offset(x, chartRect.bottom + 5),
        tickPaint,
      );
      _paintCenteredText(
        canvas,
        dateFormat.format(points[i].date),
        Offset(
          x,
          chartRect.bottom + 10 + (points.length > 5 && i.isOdd ? 13 : 0),
        ),
        9.5,
        textColor,
        FontWeight.w600,
        chartRect.left,
        chartRect.right,
      );
    }
  }

  double _yForValue(double value, Rect chartRect) {
    final normalized = (value - minY) / math.max(maxY - minY, 0.001);
    return chartRect.top + chartRect.height * (1 - normalized.clamp(0.0, 1.0));
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset offset,
    double size,
    Color color,
    FontWeight weight,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: size, color: color, fontWeight: weight),
      ),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
    )..layout();
    painter.paint(canvas, offset);
  }

  void _paintPillText(
    Canvas canvas,
    String text,
    Offset rightCenter,
    Color zoneColor,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 9.5,
          color: textColor.withValues(alpha: 0.78),
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
    )..layout();

    const horizontalPadding = 7.0;
    const verticalPadding = 3.0;
    final width = textPainter.width + horizontalPadding * 2;
    final height = textPainter.height + verticalPadding * 2;
    final rect = Rect.fromLTWH(
      rightCenter.dx,
      rightCenter.dy - height / 2,
      width,
      height,
    );
    final bgColor = Color.lerp(
      zoneColor,
      isDark ? Colors.black : Colors.white,
      0.42,
    )!;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(999)),
      Paint()..color = bgColor.withValues(alpha: isDark ? 0.72 : 0.88),
    );
    textPainter.paint(
      canvas,
      Offset(rect.left + horizontalPadding, rect.top + verticalPadding),
    );
  }

  void _paintCenteredText(
    Canvas canvas,
    String text,
    Offset centerTop,
    double size,
    Color color,
    FontWeight weight,
    double minX,
    double maxX,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: size, color: color, fontWeight: weight),
      ),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final dx = (centerTop.dx - painter.width / 2).clamp(
      minX,
      maxX - painter.width,
    );
    painter.paint(canvas, Offset(dx, centerTop.dy));
  }

  void _paintValueBubble(
    Canvas canvas,
    String text,
    Offset center,
    double minX,
    double maxX,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 10.5,
          color: isDark ? Colors.black : Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
    )..layout();
    const horizontalPadding = 6.0;
    const verticalPadding = 3.0;
    final width = painter.width + horizontalPadding * 2;
    final height = painter.height + verticalPadding * 2;
    final left = (center.dx - width / 2).clamp(minX, maxX - width);
    final rect = Rect.fromLTWH(left, center.dy - height / 2, width, height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(999)),
      Paint()..color = lineColor.withValues(alpha: 0.92),
    );
    painter.paint(
      canvas,
      Offset(rect.left + horizontalPadding, rect.top + verticalPadding),
    );
  }

  @override
  bool shouldRepaint(covariant MetricChartPainter<T> oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.zones != zones ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.minY != minY ||
        oldDelegate.maxY != maxY ||
        oldDelegate.isDark != isDark ||
        oldDelegate.showPointLabels != showPointLabels;
  }
}
