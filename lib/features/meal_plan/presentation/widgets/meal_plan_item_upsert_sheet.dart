import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_item_ingredient_response.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_item_ingredient_upsert_request.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_item_response.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_item_upsert_request.dart';
import 'package:eefood/features/meal_plan/domain/enum/meal_plan_item_source.dart';
import 'package:eefood/features/meal_plan/domain/enum/meal_plan_item_status.dart';
import 'package:eefood/features/meal_plan/domain/enum/meal_slot.dart';
import 'package:eefood/features/meal_plan/presentation/meal_plan_localizations.dart';
import 'package:eefood/features/meal_plan/presentation/provider/meal_plan_cubit.dart';
import 'package:eefood/features/meal_plan/presentation/widgets/meal_plan_ingredients_editor.dart';
import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<void> showMealPlanItemUpsertSheet({
  required BuildContext context,
  required MealPlanCubit cubit,
  required DateTime selectedDate,
  MealPlanItemResponse? item,
}) async {
  final parentContext = context;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
        ),
        child: _MealPlanItemUpsertSheetContent(
          parentContext: parentContext,
          cubit: cubit,
          selectedDate: selectedDate,
          item: item,
        ),
      );
    },
  );
}

class _MealPlanItemUpsertSheetContent extends StatefulWidget {
  final BuildContext parentContext;
  final MealPlanCubit cubit;
  final DateTime selectedDate;
  final MealPlanItemResponse? item;

  const _MealPlanItemUpsertSheetContent({
    required this.parentContext,
    required this.cubit,
    required this.selectedDate,
    required this.item,
  });

  @override
  State<_MealPlanItemUpsertSheetContent> createState() =>
      _MealPlanItemUpsertSheetContentState();
}

class _MealPlanItemUpsertSheetContentState
    extends State<_MealPlanItemUpsertSheetContent> {
  late final TextEditingController _dateController;
  late final TextEditingController _customMealNameController;
  late final TextEditingController _plannedServingsController;
  late final TextEditingController _actualServingsController;
  late final TextEditingController _noteController;
  late final List<MealPlanIngredientDraft> _ingredientDrafts;

  late DateTime _planDate;
  late MealSlot _mealSlot;
  late MealPlanItemStatus _status;
  late MealPlanItemSource _source;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;

    _planDate = item?.planDate ?? widget.selectedDate;
    _mealSlot = item?.mealSlot ?? MealSlot.breakfast;
    _status = item?.status ?? MealPlanItemStatus.planned;
    _source = item?.itemSource ?? MealPlanItemSource.custom;

    _dateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(_planDate),
    );
    _customMealNameController = TextEditingController(
      text: item?.customMealName ?? '',
    );
    _plannedServingsController = TextEditingController(
      text: item?.plannedServings?.toString() ?? '',
    );
    _actualServingsController = TextEditingController(
      text: item?.actualServings?.toString() ?? '',
    );
    _noteController = TextEditingController(text: item?.note ?? '');
    _ingredientDrafts =
        (item?.ingredients ?? const <MealPlanItemIngredientResponse>[])
            .map(MealPlanIngredientDraft.fromResponse)
            .toList();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _customMealNameController.dispose();
    _plannedServingsController.dispose();
    _actualServingsController.dispose();
    _noteController.dispose();
    for (final draft in _ingredientDrafts) {
      draft.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _planDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2, 12, 31),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _planDate = picked;
      _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final customMealName = _customMealNameController.text.trim();
    if (_source == MealPlanItemSource.custom && customMealName.isEmpty) {
      showCustomSnackBar(context, l10n.mealPlanItemNameRequired, isError: true);
      return;
    }

    final plannedServings = int.tryParse(
      _plannedServingsController.text.trim(),
    );
    final actualServings = int.tryParse(_actualServingsController.text.trim());
    final ingredients = _ingredientDrafts
        .map((draft) => draft.toRequest())
        .where((ingredient) => ingredient != null)
        .cast<MealPlanItemIngredientUpsertRequest>()
        .toList();

    await widget.cubit.upsertMealPlanItem(
      MealPlanItemUpsertRequest(
        id: widget.item?.id,
        planDate: _planDate,
        mealSlot: _mealSlot,
        itemSource: _source,
        recipeId: widget.item?.recipeId,
        postId: widget.item?.postId,
        customMealName: _source == MealPlanItemSource.custom
            ? customMealName
            : widget.item?.customMealName,
        plannedServings: plannedServings,
        actualServings: actualServings,
        status: _status,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        ingredients: ingredients.isEmpty ? null : ingredients,
      ),
    );

    if (!mounted ||
        !widget.parentContext.mounted ||
        widget.cubit.state.error != null) {
      return;
    }

    Navigator.pop(context);
    showCustomSnackBar(
      widget.parentContext,
      _isEditing ? l10n.mealPlanItemUpdated : l10n.mealPlanItemAdded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = colorScheme.primary;
    final onPrimaryColor = colorScheme.onPrimary;
    final sheetBackground = isDark
        ? Color.alphaBlend(
            colorScheme.onSurface.withValues(alpha: 0.04),
            colorScheme.surface,
          )
        : colorScheme.surface;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: sheetBackground,
        borderRadius: BorderRadius.circular(28),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(
                    alpha: isDark ? 0.26 : 0.18,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _isEditing
                  ? l10n.mealPlanEditItemTitle
                  : l10n.mealPlanAddItemTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: _pickDate,
              decoration: InputDecoration(
                labelText: l10n.mealPlanApplyDate,
                suffixIcon: const Icon(Icons.calendar_month_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<MealSlot>(
              value: _mealSlot,
              decoration: InputDecoration(
                labelText: l10n.mealPlanMealSlot,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              items: MealSlot.values
                  .map(
                    (slot) => DropdownMenuItem(
                      value: slot,
                      child: Text(slot.localizedLabel(l10n)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _mealSlot = value);
              },
            ),
            const SizedBox(height: 14),
            if (_source == MealPlanItemSource.custom) ...[
              TextField(
                controller: _customMealNameController,
                decoration: InputDecoration(
                  labelText: l10n.mealPlanItemName,
                  hintText: l10n.mealPlanItemNameHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ] else ...[
              TextFormField(
                initialValue:
                    widget.item?.recipeTitle ?? l10n.mealPlanLinkedMeal,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: l10n.mealPlanLinkedMeal,
                  helperText: l10n.mealPlanLinkedMealHelper,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _plannedServingsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.mealPlanPlannedServings,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _actualServingsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.mealPlanActualServings,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<MealPlanItemStatus>(
              value: _status,
              decoration: InputDecoration(
                labelText: l10n.mealPlanStatus,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              items: MealPlanItemStatus.values
                  .map(
                    (itemStatus) => DropdownMenuItem(
                      value: itemStatus,
                      child: Text(itemStatus.localizedLabel(l10n)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _status = value);
              },
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _noteController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.mealPlanNote,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 14),
            MealPlanIngredientsEditor(
              drafts: _ingredientDrafts,
              onAdd: () {
                setState(() {
                  _ingredientDrafts.add(MealPlanIngredientDraft.empty());
                });
              },
              onRemove: (index) {
                setState(() {
                  final draft = _ingredientDrafts.removeAt(index);
                  draft.dispose();
                });
              },
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: onPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _save,
                child: Text(
                  _isEditing ? l10n.mealPlanSaveChanges : l10n.mealPlanAddItem,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
