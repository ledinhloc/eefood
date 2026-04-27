import 'dart:math' as math;

import 'package:eefood/features/profile/presentation/widgets/metrics_page/body_metric_chart_models.dart';
import 'package:eefood/features/profile/presentation/widgets/metrics_page/body_metric_chart_painter.dart';
import 'package:flutter/material.dart';

class BodyMetricChartCard<T> extends StatefulWidget {
  static const int pageSize = 7;

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
  State<BodyMetricChartCard<T>> createState() => _BodyMetricChartCardState<T>();
}

class _BodyMetricChartCardState<T> extends State<BodyMetricChartCard<T>> {
  int _startIndex = 0;

  @override
  void initState() {
    super.initState();
    _startIndex = _defaultStartIndex;
  }

  @override
  void didUpdateWidget(covariant BodyMetricChartCard<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points.length != widget.points.length) {
      _startIndex = _defaultStartIndex;
      return;
    }
    _startIndex = _startIndex.clamp(0, _maxStartIndex);
  }

  int get _totalPages {
    if (widget.points.isEmpty) return 0;
    return ((widget.points.length - 1) / BodyMetricChartCard.pageSize).floor() +
        1;
  }

  int get _maxStartIndex {
    return math.max(0, widget.points.length - BodyMetricChartCard.pageSize);
  }

  int get _defaultStartIndex {
    final todayIndex = widget.points.indexWhere(_isToday);
    if (todayIndex == -1) return _maxStartIndex;

    // Ưu tiên hiển thị hôm nay cùng các điểm trước đó, đủ 7 điểm nếu có.
    final start = todayIndex - BodyMetricChartCard.pageSize + 1;
    return start.clamp(0, _maxStartIndex);
  }

  bool _isToday(BodyMetricChartPoint<T> point) {
    final now = DateTime.now();
    return point.date.year == now.year &&
        point.date.month == now.month &&
        point.date.day == now.day;
  }

  List<BodyMetricChartPoint<T>> get _visiblePoints {
    return widget.points
        .skip(_startIndex)
        .take(BodyMetricChartCard.pageSize)
        .toList();
  }

  int get _currentPage {
    if (widget.points.isEmpty) return 0;
    final visibleEndIndex = math.min(
      _startIndex + BodyMetricChartCard.pageSize,
      widget.points.length,
    );
    return ((visibleEndIndex - 1) / BodyMetricChartCard.pageSize).floor() + 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFF1E0D5);
    final visiblePoints = _visiblePoints;
    final minValue = _minValue(visiblePoints);
    final maxValue = _maxValue(visiblePoints);

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
            title: widget.title,
            subtitle: widget.subtitle,
            icon: widget.icon,
            accentColor: widget.accentColor,
            onAdd: widget.onAdd,
          ),
          const SizedBox(height: 14),
          if (widget.points.isEmpty)
            _EmptyChart(message: widget.emptyMessage)
          else ...[
            SizedBox(
              height: widget.zones.isEmpty ? 200 : 230,
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
                        visiblePoints,
                        minValue,
                        maxValue,
                      );
                      if (index != null) {
                        widget.onPointTap(visiblePoints[index].source);
                      }
                    },
                    child: CustomPaint(
                      painter: MetricChartPainter<T>(
                        points: visiblePoints,
                        zones: widget.zones,
                        lineColor: widget.accentColor,
                        textColor: colorScheme.onSurfaceVariant,
                        axisColor: colorScheme.outlineVariant.withValues(
                          alpha: 0.72,
                        ),
                        minY: minValue,
                        maxY: maxValue,
                        unit: widget.unit,
                        formatValue: widget.formatValue,
                        isDark: isDark,
                        showPointLabels: widget.showPointLabels,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            _ChartPager(
              accentColor: widget.accentColor,
              currentPage: _currentPage,
              totalPages: _totalPages,
              onOlder: _startIndex == 0
                  ? null
                  : () => setState(() {
                      _startIndex = math.max(
                        0,
                        _startIndex - BodyMetricChartCard.pageSize,
                      );
                    }),
              onNewer: _startIndex == _maxStartIndex
                  ? null
                  : () => setState(() {
                      _startIndex = math.min(
                        _maxStartIndex,
                        _startIndex + BodyMetricChartCard.pageSize,
                      );
                    }),
            ),
          ],
        ],
      ),
    );
  }

  double _minValue(List<BodyMetricChartPoint<T>> points) {
    if (widget.minY != null) return widget.minY!;
    if (points.isEmpty) return 0;
    // Thêm khoảng đệm để đường biểu đồ không dính sát mép.
    final min = points.map((point) => point.value).reduce(math.min);
    final max = points.map((point) => point.value).reduce(math.max);
    final padding = math.max((max - min) * 0.22, 1.0);
    return math.max(0, min - padding);
  }

  double _maxValue(List<BodyMetricChartPoint<T>> points) {
    if (widget.maxY != null) return widget.maxY!;
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

class _ChartPager extends StatelessWidget {
  final Color accentColor;
  final int currentPage;
  final int totalPages;
  final VoidCallback? onOlder;
  final VoidCallback? onNewer;

  const _ChartPager({
    required this.accentColor,
    required this.currentPage,
    required this.totalPages,
    required this.onOlder,
    required this.onNewer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: 'Xem ngày trước',
          onPressed: onOlder,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Text(
            'Trang $currentPage/$totalPages',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: 'Xem ngày sau',
          onPressed: onNewer,
          color: accentColor,
          icon: const Icon(Icons.chevron_right_rounded),
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
