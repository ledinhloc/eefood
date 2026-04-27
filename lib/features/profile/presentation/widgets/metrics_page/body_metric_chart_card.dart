import 'dart:math' as math;

import 'package:eefood/features/profile/presentation/widgets/metrics_page/body_metric_chart_models.dart';
import 'package:eefood/features/profile/presentation/widgets/metrics_page/body_metric_chart_painter.dart';
import 'package:flutter/material.dart';

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
  final String Function(double) formatValue;
  final VoidCallback? onAdd;
  final ValueChanged<T> onPointTap;
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
    required this.formatValue,
    this.onAdd,
    required this.onPointTap,
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
                      painter: MetricChartPainter<T>(
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
          ],
        ],
      ),
    );
  }

  double get _minValue {
    if (minY != null) return minY!;
    if (points.isEmpty) return 0;
    // Thêm khoảng đệm để đường biểu đồ không dính sát mép.
    final min = points.map((point) => point.value).reduce(math.min);
    final max = points.map((point) => point.value).reduce(math.max);
    final padding = math.max((max - min) * 0.22, 1.0);
    return math.max(0, min - padding);
  }

  double get _maxValue {
    if (maxY != null) return maxY!;
    if (points.isEmpty) return 1;
    // Dùng cùng quy tắc đệm với _minValue để trục Y cân đối.
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
    const padding = ChartPadding();
    final chartWidth = size.width - padding.left - padding.right;
    final chartHeight = size.height - padding.top - padding.bottom;
    var bestDistance = double.infinity;
    int? bestIndex;

    // Đổi từng điểm dữ liệu sang tọa độ màn hình rồi chọn điểm gần nhất.
    for (var i = 0; i < points.length; i++) {
      final x =
          padding.left +
          chartXForPointIndex(points: points, index: i, width: chartWidth);
      final normalized =
          (points[i].value - minY) / math.max(maxY - minY, 0.001);
      final y = padding.top + chartHeight * (1 - normalized.clamp(0.0, 1.0));
      final distance = (tap - Offset(x, y)).distance;
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }

    // Bỏ qua nếu vị trí tap quá xa mọi điểm.
    return bestDistance <= 34 ? bestIndex : null;
  }
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
