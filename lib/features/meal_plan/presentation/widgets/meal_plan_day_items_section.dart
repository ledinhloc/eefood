import 'package:eefood/core/widgets/media_view_page.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_item_response.dart';
import 'package:eefood/features/recipe/presentation/screens/recipe_detail_page.dart';
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
        return 'Bữa sáng';
      case 'LUNCH':
        return 'Bữa trưa';
      case 'DINNER':
        return 'Bữa tối';
      case 'SNACK':
        return 'Bữa phụ';
      default:
        return value;
    }
  }

  String _statusLabel(String value) {
    switch (value) {
      case 'PLANNED':
        return 'Đã lên kế hoạch';
      case 'DONE':
        return 'Đã ăn';
      case 'SKIPPED':
        return 'Đã bỏ qua';
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

  String _itemTitle(MealPlanItemResponse item) {
    if (item.recipeTitle?.trim().isNotEmpty == true) {
      return item.recipeTitle!.trim();
    }
    if (item.customMealName?.trim().isNotEmpty == true) {
      return item.customMealName!.trim();
    }
    return 'Món ăn không tên';
  }

  void _openImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MediaViewPage(
          url: imageUrl,
          isVideo: false,
        ),
      ),
    );
  }

  void _openRecipeDetail(BuildContext context, int recipeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeDetailPage(recipeId: recipeId),
      ),
    );
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
          'Ngày này chưa có món ăn.',
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
                  GestureDetector(
                    onTap: item.imageUrl?.isNotEmpty == true
                        ? () => _openImage(context, item.imageUrl!)
                        : null,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: softCream,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.network(
                                item.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.fastfood_outlined,
                                  color: primaryWarm,
                                  size: 28,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.fastfood_outlined,
                              color: primaryWarm,
                              size: 28,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
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
                        GestureDetector(
                          onTap: item.recipeId != null
                              ? () => _openRecipeDetail(
                                    context,
                                    item.recipeId!,
                                  )
                              : null,
                          child: Text(
                            _itemTitle(item),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: item.recipeId != null ? primaryWarm : null,
                              decoration: item.recipeId != null
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                              decorationColor: item.recipeId != null
                                  ? primaryWarm
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Khẩu phần: ${item.actualServings ?? item.plannedServings ?? '--'}',
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
