import 'dart:math' as math;

import 'package:eefood/features/meal_plan/data/model/meal_plan_daily_summary_response.dart';
import 'package:eefood/features/meal_plan/domain/enum/nutrition_metric.dart';
import 'package:eefood/features/meal_plan/presentation/widgets/chart/date_nav_button.dart';
import 'package:eefood/features/meal_plan/presentation/widgets/chart/nutrition_metric_dropdown.dart';
import 'package:eefood/features/meal_plan/presentation/widgets/chart/nutrition_metric_extensions.dart';
import 'package:eefood/features/meal_plan/presentation/widgets/chart/nutrition_trend_painter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  DateTime? get _firstSummaryDate {
    for (final summary in widget.summaries) {
      final planDate = summary.planDate;
      if (planDate != null) return _normalizeDate(planDate);
    }
    return null;
  }

  DateTime get _currentChartDate {
    return _normalizeDate(_chartSelectedDate ?? _resolveInitialChartDate());
  }

  Map<DateTime, MealPlanDailySummaryResponse> get _summaryByDate {
    final summaryByDate = <DateTime, MealPlanDailySummaryResponse>{};
    for (final summary in widget.summaries) {
      final planDate = summary.planDate;
      if (planDate == null) continue;
      summaryByDate[_normalizeDate(planDate)] = summary;
    }
    return summaryByDate;
  }

  List<DateTime> get _availableSummaryDates {
    final dates = _summaryByDate.keys.toList()..sort();
    return dates;
  }

  DateTime _resolveInitialChartDate() {
    final selectedDate = widget.selectedDate;
    if (selectedDate != null) return _normalizeDate(selectedDate);
    return _firstSummaryDate ?? _normalizeDate(DateTime.now());
  }

  bool _sameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _setChartSelectedDate(DateTime date) {
    setState(() {
      _chartSelectedDate = _normalizeDate(date);
    });
  }

  List<NutritionDayPoint> _buildPoints(String locale) {
    final points = <NutritionDayPoint>[];
    final anchorDate = _currentChartDate;
    final summaryByDate = _summaryByDate;

    for (var offset = -3; offset <= 3; offset++) {
      final date = DateTime(
        anchorDate.year,
        anchorDate.month,
        anchorDate.day + offset,
      );
      final summary = summaryByDate[date];

      final value = summary == null ? 0.0 : _selectedMetric.valueFrom(summary);

      points.add(
        NutritionDayPoint(
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
    final anchorDate = _currentChartDate;
    _setChartSelectedDate(
      DateTime(anchorDate.year, anchorDate.month, anchorDate.day + offset),
    );
  }

  Future<void> _pickChartDate() async {
    final summaryDates = _availableSummaryDates;
    final anchorDate = _currentChartDate;

    final firstDate = summaryDates.isNotEmpty
        ? summaryDates.first
        : DateTime(anchorDate.year - 1, 1, 1);
    final lastDate = summaryDates.isNotEmpty
        ? summaryDates.last
        : DateTime(anchorDate.year + 1, 12, 31);
    final initialDate = anchorDate.isBefore(firstDate)
        ? firstDate
        : (anchorDate.isAfter(lastDate) ? lastDate : anchorDate);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Chọn ngày cho biểu đồ',
    );

    if (pickedDate == null || !mounted) return;

    _setChartSelectedDate(pickedDate);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    final anchorDate = _currentChartDate;
    final fullWeekdayFormat = DateFormat('EEEE', locale);
    final fullDateFormat = DateFormat('dd/MM/yyyy');
    final points = _buildPoints(locale);
    final maxValue = points.fold<double>(
      0,
      (max, item) => math.max(max, item.value),
    );
    final chartColor = _selectedMetric.color(isDark);

    return Container(
      padding: const EdgeInsets.all(14),
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
              NutritionMetricDropdown(
                selectedMetric: _selectedMetric,
                isDark: isDark,
                chartColor: chartColor,
                colorScheme: colorScheme,
                textTheme: theme.textTheme,
                onChanged: (metric) {
                  setState(() {
                    _selectedMetric = metric;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              DateNavButton(
                icon: Icons.chevron_left_rounded,
                color: chartColor,
                onTap: () => _moveChartDate(-1),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _pickChartDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
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
                            fullWeekdayFormat.format(anchorDate),
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
                                fullDateFormat.format(anchorDate),
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
              const SizedBox(width: 8),
              DateNavButton(
                icon: Icons.chevron_right_rounded,
                color: chartColor,
                onTap: () => _moveChartDate(1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 196,
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
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
                    painter: NutritionTrendPainter(
                      points: points,
                      lineColor: chartColor,
                      axisColor: colorScheme.onSurface.withValues(alpha: 0.16),
                      textColor: colorScheme.onSurface.withValues(alpha: 0.48),
                      maxValue: maxValue,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: points.map((point) {
                    return Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _setChartSelectedDate(point.date),
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
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 3,
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

