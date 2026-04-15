import 'package:eefood/features/meal_plan/domain/enum/nutrition_metric.dart';
import 'package:eefood/features/meal_plan/presentation/widgets/chart/nutrition_metric_extensions.dart';
import 'package:flutter/material.dart';

Future<void> showMealPlanItemNutritionSheet({
  required BuildContext context,
  required String title,
  required String caloriesText,
  String? proteinText,
  String? carbsText,
  String? fatText,
  String? fiberText,
  String? sugarText,
  String? calciumText,
  String? sodiumText,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final metrics = <_NutritionMetricData>[
    _NutritionMetricData(
      metric: NutritionMetric.calories,
      label: 'Calo',
      value: caloriesText,
      color: NutritionMetric.calories.color(isDark),
    ),
    if (proteinText != null)
      _NutritionMetricData(
        metric: NutritionMetric.protein,
        label: 'Protein',
        value: proteinText,
        color: NutritionMetric.protein.color(isDark),
      ),
    if (carbsText != null)
      _NutritionMetricData(
        metric: NutritionMetric.carbs,
        label: 'Tinh bột',
        value: carbsText,
        color: NutritionMetric.carbs.color(isDark),
      ),
    if (fatText != null)
      _NutritionMetricData(
        metric: NutritionMetric.fat,
        label: 'Chất béo',
        value: fatText,
        color: NutritionMetric.fat.color(isDark),
      ),
    if (fiberText != null)
      _NutritionMetricData(
        metric: NutritionMetric.fiber,
        label: 'Chất xơ',
        value: fiberText,
        color: NutritionMetric.fiber.color(isDark),
      ),
    if (sugarText != null)
      _NutritionMetricData(
        metric: NutritionMetric.sugar,
        label: 'Đường',
        value: sugarText,
        color: NutritionMetric.sugar.color(isDark),
      ),
    if (calciumText != null)
      _NutritionMetricData(
        metric: NutritionMetric.calcium,
        label: 'Canxi',
        value: calciumText,
        color: NutritionMetric.calcium.color(isDark),
      ),
    if (sodiumText != null)
      _NutritionMetricData(
        metric: NutritionMetric.sodium,
        label: 'Natri',
        value: sodiumText,
        color: NutritionMetric.sodium.color(isDark),
      ),
  ];

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: _MealPlanItemNutritionSheet(title: title, metrics: metrics),
      );
    },
  );
}

class _MealPlanItemNutritionSheet extends StatelessWidget {
  final String title;
  final List<_NutritionMetricData> metrics;

  const _MealPlanItemNutritionSheet({
    required this.title,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Chi tiết dinh dưỡng',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              ...metrics.map((metric) => _NutritionMetricTile(metric: metric)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NutritionMetricTile extends StatelessWidget {
  final _NutritionMetricData metric;

  const _NutritionMetricTile({required this.metric});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: metric.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: metric.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              metric.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: metric.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            metric.value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: metric.color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionMetricData {
  final NutritionMetric metric;
  final String label;
  final String value;
  final Color color;

  const _NutritionMetricData({
    required this.metric,
    required this.label,
    required this.value,
    required this.color,
  });
}
