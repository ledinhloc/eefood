import 'package:eefood/features/meal_plan/data/model/meal_plan_daily_summary_response.dart';
import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class DailySummaryCard extends StatelessWidget {
  final MealPlanDailySummaryResponse summary;
  final bool isSelected;
  final bool isHighlighted;
  final VoidCallback onTap;
  final String chipDate;
  final String weekday;
  final String caloriesText;
  final String proteinText;
  final String carbsText;
  final String fatText;
  final String fiberText;
  final Color primaryWarm;
  final Color accentWarm;

  const DailySummaryCard({
    super.key,
    required this.summary,
    required this.isSelected,
    this.isHighlighted = false,
    required this.onTap,
    required this.chipDate,
    required this.weekday,
    required this.caloriesText,
    required this.proteinText,
    required this.carbsText,
    required this.fatText,
    required this.fiberText,
    required this.primaryWarm,
    required this.accentWarm,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final cardColor = isSelected
        ? colorScheme.primaryContainer.withValues(alpha: isDark ? 0.34 : 0.22)
        : colorScheme.surface;
    final defaultBorderColor = isDark
        ? colorScheme.onSurface.withValues(alpha: 0.14)
        : const Color(0xFFF1E5D8);
    final shadowColor = isHighlighted
        ? primaryWarm.withValues(alpha: isDark ? 0.24 : 0.18)
        : Colors.black.withValues(alpha: isDark ? 0.16 : 0.04);
    final proteinColor = isDark
        ? const Color(0xFFFF8A80)
        : const Color(0xFFD95D5D);
    final carbsColor = isDark
        ? const Color(0xFFFFCC80)
        : const Color(0xFFF29F05);
    final fatColor = isDark ? const Color(0xFFA5D6A7) : const Color(0xFF5C9E6A);
    final fiberColor = isDark
        ? const Color(0xFF90CAF9)
        : const Color(0xFF5B8DEF);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected
                  ? accentWarm
                  : (isHighlighted ? primaryWarm : defaultBorderColor),
              width: isSelected || isHighlighted ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: isHighlighted ? 20 : 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 58,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryWarm, accentWarm],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          chipDate,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          weekday,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          caloriesText,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryWarm,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.mealPlanViewing,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  if (!isSelected && isHighlighted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accentWarm,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.mealPlanNew,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _MacroPill(
                    label: l10n.mealPlanProtein,
                    value: proteinText,
                    color: proteinColor,
                  ),
                  const SizedBox(width: 6),
                  _MacroPill(
                    label: l10n.mealPlanCarbs,
                    value: carbsText,
                    color: carbsColor,
                  ),
                  const SizedBox(width: 6),
                  _MacroPill(
                    label: l10n.mealPlanFat,
                    value: fatText,
                    color: fatColor,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _MacroPill(
                    label: l10n.mealPlanFiber,
                    value: fiberText,
                    color: fiberColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
