import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:eefood/features/profile/data/models/user_height_response.dart';
import 'package:eefood/features/profile/data/models/user_weight_response.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BodyMetricChartPoint<T> {
  final DateTime date;
  final double value;
  final T source;

  const BodyMetricChartPoint({
    required this.date,
    required this.value,
    required this.source,
  });
}

class BmiZone {
  final double min;
  final double max;
  final String label;
  final Color color;

  const BmiZone({
    required this.min,
    required this.max,
    required this.label,
    required this.color,
  });

  static List<BmiZone> defaults(bool isDark) {
    return [
      BmiZone(
        min: 14,
        max: 18.5,
        label: 'Ốm',
        color: isDark ? const Color(0xFF253C50) : const Color(0xFFEAF5FF),
      ),
      BmiZone(
        min: 18.5,
        max: 25,
        label: 'Bình thường',
        color: isDark ? const Color(0xFF263E30) : const Color(0xFFEFF8E9),
      ),
      BmiZone(
        min: 25,
        max: 30,
        label: 'Thừa cân',
        color: isDark ? const Color(0xFF4A341D) : const Color(0xFFFFF2D8),
      ),
      BmiZone(
        min: 30,
        max: 34,
        label: 'Béo phì',
        color: isDark ? const Color(0xFF4B2424) : const Color(0xFFFFE4DE),
      ),
    ];
  }
}

class BodyMetricChartCard<T> extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String unit;
  final List<BodyMetricChartPoint<T>> points;
  final List<BmiZone> zones;
  final double? minY;
  final double? maxY;
  final String emptyMessage;
  final String Function(DateTime?)? formatDate;
  final String Function(double) formatValue;
  final VoidCallback? onAdd;
  final ValueChanged<T> onPointTap;
  final ValueChanged<T>? onRecordDelete;
  final bool showRecords;
  final bool showPointLabels;

  const BodyMetricChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.unit,
    required this.points,
    this.zones = const [],
    this.minY,
    this.maxY,
    required this.emptyMessage,
    this.formatDate,
    required this.formatValue,
    this.onAdd,
    required this.onPointTap,
    this.onRecordDelete,
    this.showRecords = true,
    this.showPointLabels = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFF1E0D5);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ChartHeader(
            title: title,
            subtitle: subtitle,
            icon: icon,
            accentColor: accentColor,
            onAdd: onAdd,
          ),
          const SizedBox(height: 14),
          if (points.isEmpty)
            _EmptyChart(message: emptyMessage)
          else ...[
            SizedBox(
              height: zones.isEmpty ? 200 : 230,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) {
                      final index = _hitPointIndex(
                        details.localPosition,
                        size,
                        points,
                        _minValue,
                        _maxValue,
                      );
                      if (index != null) {
                        onPointTap(points[index].source);
                      }
                    },
                    child: CustomPaint(
                      painter: _MetricChartPainter<T>(
                        points: points,
                        zones: zones,
                        lineColor: accentColor,
                        textColor: colorScheme.onSurfaceVariant,
                        axisColor: colorScheme.outlineVariant.withValues(
                          alpha: 0.72,
                        ),
                        minY: _minValue,
                        maxY: _maxValue,
                        unit: unit,
                        formatValue: formatValue,
                        isDark: isDark,
                        showPointLabels: showPointLabels,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  );
                },
              ),
            ),
            if (showRecords) ...[
              const SizedBox(height: 12),
              ...points.reversed.take(3).map((point) {
                final value = unit.isEmpty
                    ? formatValue(point.value)
                    : '${formatValue(point.value)} $unit';
                final date =
                    formatDate?.call(point.date) ??
                    DateFormat('dd/MM/yyyy').format(point.date);
                return _ChartRecordRow<T>(
                  value: value,
                  date: date,
                  accentColor: accentColor,
                  source: point.source,
                  onTap: onPointTap,
                  onDelete: onRecordDelete,
                );
              }),
            ],
          ],
        ],
      ),
    );
  }

  double get _minValue {
    if (minY != null) return minY!;
    if (points.isEmpty) return 0;
    final min = points.map((point) => point.value).reduce(math.min);
    final max = points.map((point) => point.value).reduce(math.max);
    final padding = math.max((max - min) * 0.22, 1.0);
    return math.max(0, min - padding);
  }

  double get _maxValue {
    if (maxY != null) return maxY!;
    if (points.isEmpty) return 1;
    final min = points.map((point) => point.value).reduce(math.min);
    final max = points.map((point) => point.value).reduce(math.max);
    final padding = math.max((max - min) * 0.22, 1.0);
    return max + padding;
  }

  int? _hitPointIndex(
    Offset tap,
    Size size,
    List<BodyMetricChartPoint<T>> points,
    double minY,
    double maxY,
  ) {
    if (points.isEmpty) return null;
    const padding = _ChartPadding();
    final chartWidth = size.width - padding.left - padding.right;
    final chartHeight = size.height - padding.top - padding.bottom;
    var bestDistance = double.infinity;
    int? bestIndex;

    for (var i = 0; i < points.length; i++) {
      final x =
          padding.left +
          _xForPointIndex(points: points, index: i, width: chartWidth);
      final normalized =
          (points[i].value - minY) / math.max(maxY - minY, 0.001);
      final y = padding.top + chartHeight * (1 - normalized.clamp(0.0, 1.0));
      final distance = (tap - Offset(x, y)).distance;
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }

    return bestDistance <= 34 ? bestIndex : null;
  }
}

class BmiMetricChartCard extends StatelessWidget {
  final Color accentColor;
  final bool isDark;
  final List<UserHeightResponse> heights;
  final List<UserWeightResponse> weights;
  final ValueChanged<UserWeightResponse> onPointTap;

  const BmiMetricChartCard({
    super.key,
    required this.accentColor,
    required this.isDark,
    required this.heights,
    required this.weights,
    required this.onPointTap,
  });

  @override
  Widget build(BuildContext context) {
    return BodyMetricChartCard<UserWeightResponse>(
      title: 'BMI',
      subtitle: 'BMI = kg / (m x m)',
      icon: Icons.insights_rounded,
      accentColor: accentColor,
      unit: '',
      points: _bmiPoints(heights, weights),
      minY: 14,
      maxY: 34,
      zones: BmiZone.defaults(isDark),
      emptyMessage: 'Cần ít nhất một bản ghi chiều cao và cân nặng',
      formatValue: (value) => value.toStringAsFixed(1),
      onPointTap: onPointTap,
      showRecords: false,
      showPointLabels: true,
    );
  }
}

class WeightMetricChartCard extends StatelessWidget {
  final Color accentColor;
  final List<UserWeightResponse> weights;
  final VoidCallback onAdd;
  final ValueChanged<UserWeightResponse> onPointTap;

  const WeightMetricChartCard({
    super.key,
    required this.accentColor,
    required this.weights,
    required this.onAdd,
    required this.onPointTap,
  });

  @override
  Widget build(BuildContext context) {
    return BodyMetricChartCard<UserWeightResponse>(
      title: 'Cân nặng',
      subtitle: 'Theo dõi thay đổi theo ngày',
      icon: Icons.monitor_weight_outlined,
      accentColor: accentColor,
      unit: 'kg',
      points: _weightPoints(weights),
      emptyMessage: 'Chưa có bản ghi cân nặng',
      formatValue: _formatMetricNumber,
      onAdd: onAdd,
      onPointTap: onPointTap,
      showRecords: false,
      showPointLabels: true,
    );
  }
}

class HeightMetricChartCard extends StatelessWidget {
  final Color accentColor;
  final List<UserHeightResponse> heights;
  final VoidCallback onAdd;
  final ValueChanged<UserHeightResponse> onPointTap;

  const HeightMetricChartCard({
    super.key,
    required this.accentColor,
    required this.heights,
    required this.onAdd,
    required this.onPointTap,
  });

  @override
  Widget build(BuildContext context) {
    return BodyMetricChartCard<UserHeightResponse>(
      title: 'Chiều cao',
      subtitle: 'Theo dõi thay đổi theo ngày',
      icon: Icons.height,
      accentColor: accentColor,
      unit: 'cm',
      points: _heightPoints(heights),
      emptyMessage: 'Chưa có bản ghi chiều cao',
      formatValue: _formatMetricNumber,
      onAdd: onAdd,
      onPointTap: onPointTap,
      showRecords: false,
      showPointLabels: true,
    );
  }
}

String _formatMetricNumber(double value) {
  return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);
}

List<BodyMetricChartPoint<UserHeightResponse>> _heightPoints(
  List<UserHeightResponse> heights,
) {
  return heights.reversed
      .map(
        (item) => BodyMetricChartPoint<UserHeightResponse>(
          date: item.recordedDate ?? DateTime.now(),
          value: item.heightCm,
          source: item,
        ),
      )
      .toList();
}

List<BodyMetricChartPoint<UserWeightResponse>> _weightPoints(
  List<UserWeightResponse> weights,
) {
  return weights.reversed
      .map(
        (item) => BodyMetricChartPoint<UserWeightResponse>(
          date: item.recordedDate ?? DateTime.now(),
          value: item.weightKg,
          source: item,
        ),
      )
      .toList();
}

List<BodyMetricChartPoint<UserWeightResponse>> _bmiPoints(
  List<UserHeightResponse> heights,
  List<UserWeightResponse> weights,
) {
  final sortedHeights = heights.reversed.toList();
  return weights.reversed
      .map((weight) {
        final weightDate = weight.recordedDate ?? DateTime.now();
        final matchedHeight = _heightForDate(sortedHeights, weightDate);
        final heightMeter = matchedHeight == null ? null : matchedHeight / 100;
        final bmi = heightMeter == null || heightMeter <= 0
            ? 0.0
            : weight.weightKg / (heightMeter * heightMeter);

        return BodyMetricChartPoint<UserWeightResponse>(
          date: weightDate,
          value: bmi,
          source: weight,
        );
      })
      .where((point) => point.value > 0)
      .toList();
}

double? _heightForDate(List<UserHeightResponse> heights, DateTime date) {
  UserHeightResponse? latestBeforeDate;
  UserHeightResponse? nearestAfterDate;
  for (final height in heights) {
    final heightDate = height.recordedDate;
    if (heightDate == null) continue;
    if (!heightDate.isAfter(date)) {
      latestBeforeDate = height;
    } else {
      nearestAfterDate ??= height;
    }
  }
  return latestBeforeDate?.heightCm ?? nearestAfterDate?.heightCm;
}

class _ChartHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onAdd;

  const _ChartHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: isDark ? 0.18 : 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: accentColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (onAdd != null)
          IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: isDark ? Colors.black : Colors.white,
            ),
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
          ),
      ],
    );
  }
}

class _ChartRecordRow<T> extends StatelessWidget {
  final String value;
  final String date;
  final Color accentColor;
  final T source;
  final ValueChanged<T> onTap;
  final ValueChanged<T>? onDelete;

  const _ChartRecordRow({
    required this.value,
    required this.date,
    required this.accentColor,
    required this.source,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onTap(source),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                date,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onTap(source);
                  if (value == 'delete') onDelete?.call(source);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                  if (onDelete != null)
                    const PopupMenuItem(value: 'delete', child: Text('Xóa')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  final String message;

  const _EmptyChart({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ChartPadding {
  final double left = 34;
  final double top = 14;
  final double right = 14;
  final double bottom = 48;

  const _ChartPadding();
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

int _daysBetween(DateTime start, DateTime end) {
  return _dateOnly(end).difference(_dateOnly(start)).inDays;
}

double _xForPointIndex<T>({
  required List<BodyMetricChartPoint<T>> points,
  required int index,
  required double width,
}) {
  if (points.length == 1) return width / 2;

  final firstDate = _dateOnly(points.first.date);
  final lastDate = _dateOnly(points.last.date);
  final totalDays = math.max(_daysBetween(firstDate, lastDate), 0);
  if (totalDays == 0) return width / 2;

  final pointDays = _daysBetween(firstDate, points[index].date);
  final normalized = pointDays / totalDays;
  return width * normalized.clamp(0.0, 1.0);
}

class _MetricChartPainter<T> extends CustomPainter {
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

  const _MetricChartPainter({
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
    const padding = _ChartPadding();
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
      final pillText = zone.label;
      _paintPillText(
        canvas,
        pillText,
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
    for (var i = 0; i < points.length; i++) {
      final x =
          chartRect.left +
          _xForPointIndex(points: points, index: i, width: chartRect.width);
      final y = _yForValue(points[i].value, chartRect);
      offsets.add(Offset(x, y));
    }

    if (offsets.length > 1) {
      final path = _smoothPath(offsets);
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
          _xForPointIndex(points: points, index: i, width: chartRect.width);
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
          _xForPointIndex(points: points, index: i, width: chartRect.width);
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
  bool shouldRepaint(covariant _MetricChartPainter<T> oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.zones != zones ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.minY != minY ||
        oldDelegate.maxY != maxY ||
        oldDelegate.isDark != isDark ||
        oldDelegate.showPointLabels != showPointLabels;
  }
}
