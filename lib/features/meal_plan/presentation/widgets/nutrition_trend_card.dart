import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:eefood/features/meal_plan/data/model/meal_plan_daily_summary_response.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum NutritionMetric {
  calories,
  protein,
  carbs,
  fat,
  fiber,
  sugar,
  sodium,
  calcium,
}

extension NutritionMetricX on NutritionMetric {
  String get label {
    switch (this) {
      case NutritionMetric.calories:
        return 'Calo';
      case NutritionMetric.protein:
        return 'Protein';
      case NutritionMetric.carbs:
        return 'Carbs';
      case NutritionMetric.fat:
        return 'Chất béo';
      case NutritionMetric.fiber:
        return 'Chất xơ';
      case NutritionMetric.sugar:
        return 'Đường';
      case NutritionMetric.sodium:
        return 'Natri';
      case NutritionMetric.calcium:
        return 'Canxi';
    }
  }

  Color color(bool isDark) {
    switch (this) {
      case NutritionMetric.calories:
        return isDark ? const Color(0xFFFFB347) : const Color(0xFFE76F00);
      case NutritionMetric.protein:
        return isDark ? const Color(0xFFFF8A80) : const Color(0xFFD9485F);
      case NutritionMetric.carbs:
        return isDark ? const Color(0xFFFFD166) : const Color(0xFFEE9B00);
      case NutritionMetric.fat:
        return isDark ? const Color(0xFF95D5B2) : const Color(0xFF2A9D8F);
      case NutritionMetric.fiber:
        return isDark ? const Color(0xFF90CAF9) : const Color(0xFF457B9D);
      case NutritionMetric.sugar:
        return isDark ? const Color(0xFFF8A5C2) : const Color(0xFFD65A8C);
      case NutritionMetric.sodium:
        return isDark ? const Color(0xFFC3BEF0) : const Color(0xFF7B6FD6);
      case NutritionMetric.calcium:
        return isDark ? const Color(0xFFBDE0FE) : const Color(0xFF4895EF);
    }
  }

  double valueFrom(MealPlanDailySummaryResponse summary) {
    switch (this) {
      case NutritionMetric.calories:
        return summary.calories ?? 0;
      case NutritionMetric.protein:
        return summary.protein ?? 0;
      case NutritionMetric.carbs:
        return summary.carbs ?? 0;
      case NutritionMetric.fat:
        return summary.fat ?? 0;
      case NutritionMetric.fiber:
        return summary.fiber ?? 0;
      case NutritionMetric.sugar:
        return summary.sugar ?? 0;
      case NutritionMetric.sodium:
        return summary.sodium ?? 0;
      case NutritionMetric.calcium:
        return summary.calcium ?? 0;
    }
  }
}

class NutritionTrendCard extends StatefulWidget {
  final List<MealPlanDailySummaryResponse> summaries;
  final DateTime? selectedDate;
  final Color primaryWarm;
  final Color softCream;

  const NutritionTrendCard({
    super.key,
    required this.summaries,
    required this.selectedDate,
    required this.primaryWarm,
    required this.softCream,
  });

  @override
  State<NutritionTrendCard> createState() => _NutritionTrendCardState();
}

class _NutritionTrendCardState extends State<NutritionTrendCard> {
  NutritionMetric _selectedMetric = NutritionMetric.calories;
  DateTime? _chartSelectedDate;

  @override
  void initState() {
    super.initState();
    _chartSelectedDate = _resolveInitialChartDate();
  }

  @override
  void didUpdateWidget(covariant NutritionTrendCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_chartSelectedDate == null ||
        (oldWidget.summaries.isEmpty && widget.summaries.isNotEmpty)) {
      _chartSelectedDate = _resolveInitialChartDate();
    }
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _resolveInitialChartDate() {
    final selectedDate = widget.selectedDate;
    if (selectedDate != null) return _normalizeDate(selectedDate);

    final firstSummary = widget.summaries.firstWhere(
      (summary) => summary.planDate != null,
      orElse: () => MealPlanDailySummaryResponse(planDate: DateTime.now()),
    ).planDate;

    return _normalizeDate(firstSummary ?? DateTime.now());
  }

  DateTime get _anchorDate {
    return _normalizeDate(_chartSelectedDate ?? _resolveInitialChartDate());
  }

  bool _sameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<_NutritionDayPoint> _buildPoints() {
    final points = <_NutritionDayPoint>[];
    final locale = Localizations.localeOf(context).languageCode;

    for (var offset = -3; offset <= 3; offset++) {
      final date = DateTime(
        _anchorDate.year,
        _anchorDate.month,
        _anchorDate.day + offset,
      );

      MealPlanDailySummaryResponse? summary;
      for (final item in widget.summaries) {
        if (_sameDay(item.planDate, date)) {
          summary = item;
          break;
        }
      }

      final value = summary == null ? 0.0 : _selectedMetric.valueFrom(summary);

      points.add(
        _NutritionDayPoint(
          date: date,
          value: value,
          isSelected: _sameDay(date, _chartSelectedDate),
          weekday: DateFormat('EEE', locale).format(date),
          dayLabel: DateFormat('dd/MM').format(date),
        ),
      );
    }

    return points;
  }

  void _moveChartDate(int offset) {
    setState(() {
      _chartSelectedDate = DateTime(
        _anchorDate.year,
        _anchorDate.month,
        _anchorDate.day + offset,
      );
    });
  }

  Future<void> _pickChartDate() async {
    final summaryDates = widget.summaries
        .map((summary) => summary.planDate)
        .whereType<DateTime>()
        .map(_normalizeDate)
        .toList()
      ..sort();

    final firstDate = summaryDates.isNotEmpty
        ? summaryDates.first
        : DateTime(_anchorDate.year - 1, 1, 1);
    final lastDate = summaryDates.isNotEmpty
        ? summaryDates.last
        : DateTime(_anchorDate.year + 1, 12, 31);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _anchorDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Chọn ngày cho biểu đồ',
    );

    if (pickedDate == null || !mounted) return;

    setState(() {
      _chartSelectedDate = _normalizeDate(pickedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final points = _buildPoints();
    final maxValue = points.fold<double>(
      0,
      (max, item) => math.max(max, item.value),
    );
    final chartColor = _selectedMetric.color(isDark);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colorScheme.surface,
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.84),
                ]
              : [Colors.white, widget.softCream],
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFF4DCC8),
        ),
        boxShadow: [
          BoxShadow(
            color: widget.primaryWarm.withValues(alpha: isDark ? 0.18 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Dinh dưỡng 7 ngày',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 156,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: isDark ? 0.04 : 0.7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: chartColor.withValues(
                        alpha: isDark ? 0.28 : 0.22,
                      ),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<NutritionMetric>(
                      value: _selectedMetric,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(18),
                      dropdownColor: isDark
                          ? colorScheme.surfaceContainerHigh
                          : Colors.white,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: chartColor,
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                      onChanged: (metric) {
                        if (metric == null) return;
                        setState(() {
                          _selectedMetric = metric;
                        });
                      },
                      items: NutritionMetric.values.map((metric) {
                        final metricColor = metric.color(isDark);

                        return DropdownMenuItem<NutritionMetric>(
                          value: metric,
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: metricColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  metric.label,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _DateNavButton(
                icon: Icons.chevron_left_rounded,
                color: chartColor,
                onTap: () => _moveChartDate(-1),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _pickChartDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: chartColor.withValues(
                          alpha: isDark ? 0.14 : 0.10,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            DateFormat(
                              'EEEE',
                              Localizations.localeOf(context).languageCode,
                            ).format(_anchorDate),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: chartColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat('dd/MM/yyyy').format(_anchorDate),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.calendar_month_rounded,
                                size: 16,
                                color: chartColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _DateNavButton(
                icon: Icons.chevron_right_rounded,
                color: chartColor,
                onTap: () => _moveChartDate(1),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 220,
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha: 0.04),
                        Colors.white.withValues(alpha: 0.02),
                      ]
                    : [
                        const Color(0xFFFFFCF7),
                        const Color(0xFFFFF4E8),
                      ],
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFF3DCC7),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: CustomPaint(
                    painter: _NutritionTrendPainter(
                      points: points,
                      lineColor: chartColor,
                      axisColor: colorScheme.onSurface.withValues(alpha: 0.16),
                      textColor: colorScheme.onSurface.withValues(alpha: 0.48),
                      maxValue: maxValue,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: points.map((point) {
                    return Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          setState(() {
                            _chartSelectedDate = _normalizeDate(point.date);
                          });
                        },
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  point.weekday,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: point.isSelected
                                        ? chartColor
                                        : colorScheme.onSurface.withValues(
                                            alpha: 0.58,
                                          ),
                                    fontWeight: point.isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: point.isSelected
                                    ? chartColor.withValues(
                                        alpha: isDark ? 0.20 : 0.14,
                                      )
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  point.dayLabel,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: point.isSelected
                                        ? chartColor
                                        : colorScheme.onSurface.withValues(
                                            alpha: 0.64,
                                          ),
                                    fontWeight: point.isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionDayPoint {
  final DateTime date;
  final double value;
  final bool isSelected;
  final String weekday;
  final String dayLabel;

  const _NutritionDayPoint({
    required this.date,
    required this.value,
    required this.isSelected,
    required this.weekday,
    required this.dayLabel,
  });
}

class _DateNavButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DateNavButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: color.withValues(alpha: isDark ? 0.16 : 0.10),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: color),
        ),
      ),
    );
  }
}

class _NutritionTrendPainter extends CustomPainter {
  final List<_NutritionDayPoint> points;
  final Color lineColor;
  final Color axisColor;
  final Color textColor;
  final double maxValue;

  const _NutritionTrendPainter({
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
  bool shouldRepaint(covariant _NutritionTrendPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.axisColor != axisColor ||
        oldDelegate.maxValue != maxValue;
  }
}
