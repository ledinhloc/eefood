import 'dart:math' as math;

import 'package:flutter/material.dart';

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

class ChartPadding {
  final double left = 34;
  final double top = 14;
  final double right = 14;
  final double bottom = 48;

  const ChartPadding();
}

DateTime chartDateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

int chartDaysBetween(DateTime start, DateTime end) {
  return chartDateOnly(end).difference(chartDateOnly(start)).inDays;
}

// Hàm này tính tọa độ X của một điểm trên chart.
double chartXForPointIndex<T>({
  required List<BodyMetricChartPoint<T>> points,
  required int index,
  required double width,
}) {
  if (points.length == 1) return width / 2;

  // Giãn điểm theo khoảng cách ngày thật, không theo vị trí trong danh sách.
  final firstDate = chartDateOnly(points.first.date);
  final lastDate = chartDateOnly(points.last.date);
  final totalDays = math.max(chartDaysBetween(firstDate, lastDate), 0);
  if (totalDays == 0) return width / 2;

  final pointDays = chartDaysBetween(firstDate, points[index].date);
  final normalized = pointDays / totalDays;
  return width * normalized.clamp(0.0, 1.0);
}
