import 'package:eefood/core/widgets/media_view_page.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_item_ingredient_upsert_request.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_item_response.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_item_upsert_request.dart';
import 'package:eefood/features/meal_plan/domain/enum/meal_plan_item_status.dart';
import 'package:eefood/features/meal_plan/domain/enum/meal_slot.dart';
import 'package:eefood/features/meal_plan/presentation/provider/meal_plan_cubit.dart';
import 'package:eefood/features/meal_plan/presentation/widgets/item_day/meal_plan_item_nutrition_sheet.dart';
import 'package:eefood/features/meal_plan/presentation/widgets/item_day/meal_plan_selection_panel.dart';
import 'package:eefood/features/meal_plan/presentation/widgets/item_day/nutrition_badge.dart';
import 'package:eefood/features/meal_plan/presentation/widgets/item_day/status_drop_down.dart';
import 'package:eefood/features/meal_plan/presentation/widgets/meal_plan_regenerate_sheet.dart';
import 'package:eefood/features/meal_plan/presentation/widgets/update_item/meal_plan_item_upsert_sheet.dart';
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
  State<MealPlanDayItemsSection> createState() =>
      _MealPlanDayItemsSectionState();
}

class _MealPlanDayItemsSectionState extends State<MealPlanDayItemsSection> {
  final Set<int> _updatingItemIds = <int>{};
  final Set<int> _selectedItemIds = <int>{};

  bool get _isSelecting => _selectedItemIds.isNotEmpty;

  @override
  void didUpdateWidget(covariant MealPlanDayItemsSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedDate != widget.selectedDate) {
      _selectedItemIds.clear();
      return;
    }

    final selectableIds = widget.items
        .where((item) => item.status != MealPlanItemStatus.done)
        .map((item) => item.id)
        .whereType<int>()
        .toSet();
    _selectedItemIds.removeWhere((id) => !selectableIds.contains(id));
  }

  void _toggleSelection(MealPlanItemResponse item) {
    final itemId = item.id;
    if (itemId == null || item.status == MealPlanItemStatus.done) return;

    setState(() {
      if (!_selectedItemIds.add(itemId)) {
        _selectedItemIds.remove(itemId);
      }
    });
  }

  Future<void> _showRegenerateSheet(BuildContext context) async {
    if (_selectedItemIds.isEmpty) return;

    final success = await showMealPlanRegenerateSheet(
      context: context,
      cubit: context.read<MealPlanCubit>(),
      itemIds: _selectedItemIds.toList(),
    );

    if (!mounted || success != true) return;

    setState(() {
      _selectedItemIds.clear();
    });
    showCustomSnackBar(
      this.context,
      AppLocalizations.of(this.context)!.mealPlanRegenerateSuccess,
    );
  }

  String _value(num? value, {String suffix = ''}) {
    if (value == null) return '--';
    final formatted = value % 1 == 0
        ? value.toInt().toString()
        : value.toString();
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

  Future<void> _showNutritionDialog(
    BuildContext context,
    MealPlanItemResponse item,
  ) async {
    if (!(item.calories != null ||
        item.protein != null ||
        item.carbs != null ||
        item.fat != null ||
        item.fiber != null ||
        item.sugar != null ||
        item.calcium != null ||
        item.sodium != null)) {
      showCustomSnackBar(context, 'Món này chưa có thông tin dinh dưỡng.');
      return;
    }

    await showMealPlanItemNutritionSheet(
      context: context,
      title: _itemTitle(context, item),
      caloriesText: _value(item.calories, suffix: ' kcal'),
      proteinText: item.protein == null
          ? null
          : _value(item.protein, suffix: ' g'),
      carbsText: item.carbs == null ? null : _value(item.carbs, suffix: ' g'),
      fatText: item.fat == null ? null : _value(item.fat, suffix: ' g'),
      fiberText: item.fiber == null ? null : _value(item.fiber, suffix: ' g'),
      sugarText: item.sugar == null ? null : _value(item.sugar, suffix: ' g'),
      calciumText: item.calcium == null
          ? null
          : _value(item.calcium, suffix: ' mg'),
      sodiumText: item.sodium == null
          ? null
          : _value(item.sodium, suffix: ' mg'),
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

    final error = cubit.state.itemSubmitError;
    if (error != null) {
      showCustomSnackBar(this.context, error, isError: true);
      return;
    }

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
          onAdd: _isSelecting || widget.selectedDate == null
              ? null
              : () => _openUpsertSheet(context),
        ),
        if (_isSelecting) ...[
          const SizedBox(height: 10),
          MealPlanSelectionPanel(
            selectedItemCount: _selectedItemIds.length,
            primaryWarm: widget.primaryWarm,
            onCancel: () {
              setState(() {
                _selectedItemIds.clear();
              });
            },
            onRegenerate: () => _showRegenerateSheet(context),
          ),
        ],
        const SizedBox(height: 10),
        ...widget.items.map((item) {
          final itemId = item.id;
          final canSelect =
              itemId != null && item.status != MealPlanItemStatus.done;
          final isSelected =
              itemId != null && _selectedItemIds.contains(itemId);

          return GestureDetector(
            onLongPress: canSelect ? () => _toggleSelection(item) : null,
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? widget.primaryWarm : borderColor,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final imageSize = (constraints.maxWidth * 0.32).clamp(
                        72.0,
                        116.0,
                      );
                      final spacing = (constraints.maxWidth * 0.03).clamp(
                        6.0,
                        10.0,
                      );
                      final contentWidth =
                          constraints.maxWidth - imageSize - spacing;
                      final actionButtonSize = contentWidth < 170 ? 24.0 : 28.0;
                      final actionIconSize = contentWidth < 170 ? 15.0 : 16.0;
                      final chipHorizontalPadding = contentWidth < 170
                          ? 6.0
                          : 8.0;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: item.imageUrl?.isNotEmpty == true
                                  ? () => _openImage(context, item.imageUrl!)
                                  : null,
                              borderRadius: BorderRadius.circular(18),
                              child: SizedBox(
                                width: imageSize,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: imageSize,
                                      height: imageSize,
                                      decoration: BoxDecoration(
                                        color: widget.softCream,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child:
                                          item.imageUrl != null &&
                                              item.imageUrl!.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              child: Image.network(
                                                item.imageUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Icon(
                                                      Icons.fastfood_outlined,
                                                      color: widget.primaryWarm,
                                                      size: 32,
                                                    ),
                                              ),
                                            )
                                          : Icon(
                                              Icons.fastfood_outlined,
                                              color: widget.primaryWarm,
                                              size: 32,
                                            ),
                                    ),
                                    if (item.calories != null)
                                      const SizedBox(height: 8),
                                    if (item.calories != null)
                                      NutritionBadge(
                                        text: _value(
                                          item.calories,
                                          suffix: ' kcal',
                                        ),
                                        textColor: tertiaryTextColor,
                                        onTap: () =>
                                            _showNutritionDialog(context, item),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: spacing),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        height: 28,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: chipHorizontalPadding,
                                        ),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: widget.softCream,
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Text(
                                          item.mealSlot.localizedLabel(l10n),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: widget.primaryWarm,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: spacing),
                                    IconButton(
                                      onPressed: () =>
                                          _openUpsertSheet(context, item: item),
                                      icon: Icon(
                                        Icons.edit_outlined,
                                        size: actionIconSize,
                                      ),
                                      tooltip: l10n.mealPlanEditItemTooltip,
                                      color: widget.primaryWarm,
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints.tightFor(
                                        width: actionButtonSize,
                                        height: actionButtonSize,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          _handleDeleteItem(context, item),
                                      icon: Icon(
                                        Icons.delete_outline,
                                        size: actionIconSize,
                                      ),
                                      tooltip: l10n.mealPlanDeleteItemTooltip,
                                      color: colorScheme.error,
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints.tightFor(
                                        width: actionButtonSize,
                                        height: actionButtonSize,
                                      ),
                                      visualDensity: VisualDensity.compact,
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
                                    _itemTitle(context, item),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      height: 1.15,
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
                                    fontSize: 11,
                                    color: secondaryTextColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: StatusDropdown(
                                    width: (contentWidth * 0.72).clamp(
                                      112.0,
                                      150.0,
                                    ),
                                    value: item.status,
                                    isBusy: _updatingItemIds.contains(item.id),
                                    textColor: item.status.textColor(isDark),
                                    borderColor: item.status.borderColor(
                                      isDark,
                                    ),
                                    fillColor: item.status.backgroundColor(
                                      isDark,
                                    ),
                                    onChanged: (value) {
                                      if (value == null) return;
                                      _updateItemStatus(context, item, value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                if (_isSelecting)
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: canSelect ? () => _toggleSelection(item) : () {},
                      ),
                    ),
                  ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: CircleAvatar(
                      radius: 13,
                      backgroundColor: widget.primaryWarm,
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 17,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
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
