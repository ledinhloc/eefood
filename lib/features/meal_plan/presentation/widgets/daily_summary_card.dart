import 'package:eefood/features/meal_plan/data/model/meal_plan_daily_summary_response.dart';
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
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFF4E6) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected
                  ? accentWarm
                  : (isHighlighted ? primaryWarm : const Color(0xFFF1E5D8)),
              width: isSelected || isHighlighted ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isHighlighted
                    ? primaryWarm.withValues(alpha: 0.18)
                    : Colors.black.withValues(alpha: 0.04),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          caloriesText,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isSelected
                              ? 'Dang duoc chon de xem chi tiet ngay'
                              : 'Cham de chon ngay nay',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.brown.shade600,
                            fontWeight: FontWeight.w600,
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
                      child: const Text(
                        'Dang xem',
                        style: TextStyle(
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
                      child: const Text(
                        'Moi',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _MacroPill(
                    label: 'Chat dam',
                    value: proteinText,
                    color: const Color(0xFFD94841),
                  ),
                  const SizedBox(width: 8),
                  _MacroPill(
                    label: 'Tinh bot',
                    value: carbsText,
                    color: const Color(0xFFF48C06),
                  ),
                  const SizedBox(width: 8),
                  _MacroPill(
                    label: 'Chat beo',
                    value: fatText,
                    color: const Color(0xFF6A994E),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _MacroPill(
                    label: 'Chat xo',
                    value: fiberText,
                    color: const Color(0xFF577590),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
