import 'package:eefood/core/widgets/media_view_page.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_item_ingredient_upsert_request.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_item_response.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_item_upsert_request.dart';
import 'package:eefood/features/meal_plan/domain/enum/meal_plan_item_status.dart';
import 'package:eefood/features/meal_plan/domain/enum/meal_slot.dart';
import 'package:eefood/features/meal_plan/presentation/provider/meal_plan_cubit.dart';
import 'package:eefood/features/meal_plan/presentation/widgets/item_day/status_drop_down.dart';
import 'package:eefood/features/meal_plan/presentation/widgets/meal_plan_item_upsert_sheet.dart';
import 'package:eefood/features/recipe/presentation/screens/recipe_detail_page.dart';
import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MealPlanDayItemsSection extends StatefulWidget {
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

  @override
  State<MealPlanDayItemsSection> createState() => _MealPlanDayItemsSectionState();
}

class _MealPlanDayItemsSectionState extends State<MealPlanDayItemsSection> {
  final Set<int> _updatingItemIds = <int>{};

  String _value(num? value, {String suffix = ''}) {
    if (value == null) return '--';
    final formatted = value % 1 == 0
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
    return '$formatted$suffix';
  }

  String _itemTitle(BuildContext context, MealPlanItemResponse item) {
    if (item.recipeTitle?.trim().isNotEmpty == true) {
      return item.recipeTitle!.trim();
    }
    if (item.customMealName?.trim().isNotEmpty == true) {
      return item.customMealName!.trim();
    }
    return AppLocalizations.of(context)!.mealPlanUnnamedItem;
  }

  void _openImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MediaViewPage(url: imageUrl, isVideo: false),
      ),
    );
  }

  void _openRecipeDetail(BuildContext context, int recipeId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecipeDetailPage(recipeId: recipeId)),
    );
  }

  Future<void> _openUpsertSheet(
    BuildContext context, {
    MealPlanItemResponse? item,
  }) async {
    final targetDate = item?.planDate ?? widget.selectedDate;
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
    final l10n = AppLocalizations.of(context)!;
    final itemId = item.id;
    if (itemId == null) {
      showCustomSnackBar(context, l10n.mealPlanCannotDeleteItem, isError: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.mealPlanDeleteItemTitle),
          content: Text(
            l10n.mealPlanDeleteItemMessage(_itemTitle(context, item)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
                foregroundColor: Theme.of(dialogContext).colorScheme.onError,
              ),
              child: Text(l10n.mealPlanDeleteAction),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;
    await context.read<MealPlanCubit>().deleteMealPlanItem(itemId);
  }

  Future<void> _updateItemStatus(
    BuildContext context,
    MealPlanItemResponse item,
    MealPlanItemStatus nextStatus,
  ) async {
    final itemId = item.id;
    if (itemId == null || item.status == nextStatus) return;

    setState(() {
      _updatingItemIds.add(itemId);
    });

    final cubit = context.read<MealPlanCubit>();
    await cubit.upsertMealPlanItem(
      MealPlanItemUpsertRequest(
        id: itemId,
        planDate: item.planDate ?? widget.selectedDate,
        mealSlot: item.mealSlot,
        itemOrder: item.itemOrder,
        itemSource: item.itemSource,
        recipeId: item.recipeId,
        postId: item.postId,
        customMealName: item.customMealName,
        plannedServings: item.plannedServings,
        actualServings: item.actualServings,
        status: nextStatus,
        note: item.note,
        ingredients: item.ingredients
            .map(
              (ingredient) => MealPlanItemIngredientUpsertRequest(
                name: ingredient.name,
                quantity: ingredient.quantity,
                unit: ingredient.unit,
                note: ingredient.note,
              ),
            )
            .toList(),
      ),
      showSubmittingState: false,
    );

    if (!mounted) return;

    setState(() {
      _updatingItemIds.remove(itemId);
    });

    final error = cubit.state.error;
    if (error != null) {
      showCustomSnackBar(this.context, error, isError: true);
      return;
    }

    // showCustomSnackBar(
    //   this.context,
    //   AppLocalizations.of(this.context)!.mealPlanItemUpdated,
    // );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final cardColor = colorScheme.surface;
    final borderColor = isDark
        ? colorScheme.onSurface.withValues(alpha: 0.14)
        : const Color(0xFFF2E6D9);
    final secondaryTextColor = isDark
        ? colorScheme.onSurface.withValues(alpha: 0.72)
        : Colors.brown.shade600;
    final tertiaryTextColor = isDark
        ? colorScheme.onSurface.withValues(alpha: 0.84)
        : Colors.brown.shade700;
    final shadowColor = Colors.black.withValues(alpha: isDark ? 0.16 : 0.04);

    if (widget.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              onAdd: widget.selectedDate == null
                  ? null
                  : () => _openUpsertSheet(context),
            ),
            const SizedBox(height: 10),
            Text(l10n.mealPlanNoItemsForDay, style: theme.textTheme.bodyMedium),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          onAdd: widget.selectedDate == null
              ? null
              : () => _openUpsertSheet(context),
        ),
        const SizedBox(height: 10),
        ...widget.items.map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
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
                      color: widget.softCream,
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
                                color: widget.primaryWarm,
                                size: 28,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.fastfood_outlined,
                            color: widget.primaryWarm,
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
                              color: widget.softCream,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              item.mealSlot.localizedLabel(l10n),
                              style: TextStyle(
                                color: widget.primaryWarm,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () =>
                                _openUpsertSheet(context, item: item),
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            tooltip: l10n.mealPlanEditItemTooltip,
                            color: widget.primaryWarm,
                          ),
                          IconButton(
                            onPressed: () => _handleDeleteItem(context, item),
                            icon: const Icon(Icons.delete_outline, size: 20),
                            tooltip: l10n.mealPlanDeleteItemTooltip,
                            color: colorScheme.error,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: item.recipeId != null
                            ? () => _openRecipeDetail(context, item.recipeId!)
                            : null,
                        child: Text(
                          _itemTitle(context, item),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: item.recipeId != null
                                ? widget.primaryWarm
                                : null,
                            decoration: item.recipeId != null
                                ? TextDecoration.underline
                                : TextDecoration.none,
                            decorationColor: item.recipeId != null
                                ? widget.primaryWarm
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.mealPlanServings(
                          '${item.actualServings ?? item.plannedServings ?? '--'}',
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.calories != null)
                                  Text(
                                    _value(item.calories, suffix: ' kcal'),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: tertiaryTextColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 132),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: StatusDropdown(
                                value: item.status,
                                isBusy: _updatingItemIds.contains(item.id),
                                textColor: secondaryTextColor,
                                borderColor: borderColor,
                                fillColor: widget.softCream,
                                onChanged: (value) {
                                  if (value == null) return;
                                  _updateItemStatus(context, item, value);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
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
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.mealPlanDayItemsTitle,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_circle_outline),
          label: Text(l10n.mealPlanAddItem),
        ),
      ],
    );
  }
}

