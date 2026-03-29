import 'package:eefood/features/meal_plan/data/model/meal_plan_item_response.dart';
import 'package:flutter/material.dart';

class MealPlanDayItemsSection extends StatelessWidget {
  final bool isLoading;
  final List<MealPlanItemResponse> items;
  final Color primaryWarm;
  final Color softCream;

  const MealPlanDayItemsSection({
    super.key,
    required this.isLoading,
    required this.items,
    required this.primaryWarm,
    required this.softCream,
  });

  String _mealSlotLabel(String value) {
    switch (value) {
      case 'BREAKFAST':
        return 'Bua sang';
      case 'LUNCH':
        return 'Bua trua';
      case 'DINNER':
        return 'Bua toi';
      case 'SNACK':
        return 'Bua phu';
      default:
        return value;
    }
  }

  String _statusLabel(String value) {
    switch (value) {
      case 'PLANNED':
        return 'Da len ke hoach';
      case 'DONE':
        return 'Da an';
      case 'SKIPPED':
        return 'Da bo qua';
      default:
        return value;
    }
  }

  String _value(num? value, {String suffix = ''}) {
    if (value == null) return '--';
    final formatted = value % 1 == 0
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
    return '$formatted$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          'Ngay nay chua co mon an.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      children: items
          .map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF2E6D9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: softCream,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              item.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.fastfood_outlined,
                                color: primaryWarm,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.fastfood_outlined,
                            color: primaryWarm,
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: softCream,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                _mealSlotLabel(item.mealSlot.value),
                                style: TextStyle(
                                  color: primaryWarm,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _statusLabel(item.status.value),
                                style: TextStyle(
                                  color: Colors.brown.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.recipeTitle?.trim().isNotEmpty == true
                              ? item.recipeTitle!.trim()
                              : (item.customMealName?.trim().isNotEmpty == true
                                  ? item.customMealName!.trim()
                                  : 'Mon an khong ten'),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Khau phan: ${item.actualServings ?? item.plannedServings ?? '--'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.brown.shade600,
                          ),
                        ),
                        if (item.calories != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            _value(item.calories, suffix: ' kcal'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.brown.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
