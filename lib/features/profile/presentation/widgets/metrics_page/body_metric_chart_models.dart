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

// Hàm này tính tọa độ X của một điểm trên chart.
double chartXForPointIndex<T>({
  required List<BodyMetricChartPoint<T>> points,
  required int index,
  required double width,
}) {
  if (points.length == 1) return width / 2;

  // Chia đều theo thứ tự điểm để chart luôn dễ đọc trên màn nhỏ.
  return width * (index / (points.length - 1));
}
