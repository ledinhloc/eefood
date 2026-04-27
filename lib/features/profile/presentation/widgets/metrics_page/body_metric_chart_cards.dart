import 'package:eefood/features/profile/data/models/user_height_response.dart';
import 'package:eefood/features/profile/data/models/user_weight_response.dart';
import 'package:eefood/features/profile/presentation/widgets/metrics_page/body_metric_chart_card.dart';
import 'package:eefood/features/profile/presentation/widgets/metrics_page/body_metric_chart_models.dart';
import 'package:flutter/material.dart';

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
