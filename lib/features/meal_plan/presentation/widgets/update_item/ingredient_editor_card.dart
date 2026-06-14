import 'package:eefood/features/meal_plan/presentation/widgets/update_item/meal_plan_ingredient_draft.dart';
import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class IngredientEditorCard extends StatelessWidget {
  final MealPlanIngredientDraft draft;
  final VoidCallback onRemove;

  const IngredientEditorCard({
    required this.draft,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final accentColor = isDark ? colorScheme.primary : const Color(0xFFE85D04);
    final cardColor = isDark
        ? colorScheme.surface
        : const Color(0xFFFFF7ED);
    final fieldColor = isDark
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.45)
        : Colors.white;
    final borderColor = isDark
        ? colorScheme.onSurface.withValues(alpha: 0.14)
        : const Color(0xFFF6D7B8);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: draft.nameController,
                  decoration: InputDecoration(
                    hintText: l10n.mealPlanIngredientName,
                    isDense: true,
                    filled: true,
                    fillColor: fieldColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: borderColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: accentColor, width: 1.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: onRemove,
                icon: Icon(Icons.delete_outline, color: colorScheme.error),
                tooltip: l10n.mealPlanDeleteIngredientTooltip,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: draft.quantityController,
                  decoration: InputDecoration(
                    hintText: l10n.mealPlanIngredientQuantity,
                    isDense: true,
                    filled: true,
                    fillColor: fieldColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: borderColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: accentColor, width: 1.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: draft.unitController,
                  decoration: InputDecoration(
                    hintText: l10n.mealPlanIngredientUnit,
                    isDense: true,
                    filled: true,
                    fillColor: fieldColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: borderColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: accentColor, width: 1.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: draft.noteController,
            minLines: 1,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: l10n.mealPlanIngredientNote,
              isDense: true,
              filled: true,
              fillColor: fieldColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: borderColor),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: accentColor, width: 1.4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
