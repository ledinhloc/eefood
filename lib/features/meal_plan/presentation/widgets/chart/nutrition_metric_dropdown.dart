import 'package:eefood/features/meal_plan/domain/enum/nutrition_metric.dart';
import 'package:eefood/features/meal_plan/presentation/widgets/chart/nutrition_metric_extensions.dart';
import 'package:flutter/material.dart';

class NutritionMetricDropdown extends StatelessWidget {
  final NutritionMetric selectedMetric;
  final bool isDark;
  final Color chartColor;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final ValueChanged<NutritionMetric> onChanged;

  const NutritionMetricDropdown({
    super.key,
    required this.selectedMetric,
    required this.isDark,
    required this.chartColor,
    required this.colorScheme,
    required this.textTheme,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 156,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: isDark ? 0.04 : 0.7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: chartColor.withValues(alpha: isDark ? 0.28 : 0.22),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<NutritionMetric>(
            value: selectedMetric,
            isExpanded: true,
            borderRadius: BorderRadius.circular(18),
            dropdownColor: isDark
                ? colorScheme.surfaceContainerHigh
                : Colors.white,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: chartColor,
            ),
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
            onChanged: (metric) {
              if (metric != null) onChanged(metric);
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
    );
  }
}
