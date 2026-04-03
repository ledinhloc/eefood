import 'package:eefood/core/widgets/media_view_page.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_item_response.dart';
import 'package:eefood/features/meal_plan/domain/enum/meal_plan_item_status.dart';
import 'package:eefood/features/meal_plan/domain/enum/meal_slot.dart';
import 'package:eefood/features/meal_plan/presentation/provider/meal_plan_cubit.dart';
import 'package:eefood/features/meal_plan/presentation/widgets/meal_plan_item_upsert_sheet.dart';
import 'package:eefood/features/recipe/presentation/screens/recipe_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MealPlanDayItemsSection extends StatelessWidget {
  final bool isLoading;
  final List<MealPlanItemResponse> items;
  final DateTime? selectedDate;
  final Color primaryWarm;
  final Color softCream;

  const MealPlanDayItemsSection({
    super.key,
    required this.isLoading,
    required this.items,
    required this.selectedDate,
    required this.primaryWarm,
    required this.softCream,
  });

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

  Future<void> _openUpsertSheet(
    BuildContext context, {
    MealPlanItemResponse? item,
  }) async {
    final targetDate = item?.planDate ?? selectedDate;
    if (targetDate == null) return;

    await showMealPlanItemUpsertSheet(
      context: context,
      cubit: context.read<MealPlanCubit>(),
      selectedDate: targetDate,
      item: item,
    );
  }

  Future<void> _handleDeleteItem(
    BuildContext context,
    MealPlanItemResponse item,
  ) async {
    final itemId = item.id;
    if (itemId == null) {
      showCustomSnackBar(
        context,
        'Không thể xóa món ăn này',
        isError: true,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xóa món ăn'),
          content: Text(
            'Bạn có chắc muốn xóa "${_itemTitle(item)}" khỏi meal plan không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    await context.read<MealPlanCubit>().deleteMealPlanItem(itemId);
    if (!context.mounted) return;

    // if (context.read<MealPlanCubit>().state.error == null) {
    //   showCustomSnackBar(context, 'Đã xóa món ăn khỏi meal plan');
    // }
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              onAdd: selectedDate == null ? null : () => _openUpsertSheet(context),
            ),
            const SizedBox(height: 10),
            Text(
              'Ngày này chưa có món ăn.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          onAdd: selectedDate == null ? null : () => _openUpsertSheet(context),
        ),
        const SizedBox(height: 10),
        ...items.map(
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
                              item.mealSlot.label,
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
                              item.status.label,
                              style: TextStyle(
                                color: Colors.brown.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _openUpsertSheet(context, item: item),
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            tooltip: 'Chỉnh sửa món ăn',
                            color: primaryWarm,
                          ),
                          IconButton(
                            onPressed: () => _handleDeleteItem(context, item),
                            icon: const Icon(Icons.delete_outline, size: 20),
                            tooltip: 'Xóa món ăn',
                            color: Colors.red.shade400,
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
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final VoidCallback? onAdd;

  const _SectionHeader({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Món ăn trong ngày',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Thêm món'),
        ),
      ],
    );
  }
}
