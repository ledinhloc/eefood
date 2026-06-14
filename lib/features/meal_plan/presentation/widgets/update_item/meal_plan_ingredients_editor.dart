import 'package:eefood/features/meal_plan/presentation/widgets/update_item/ingredient_editor_card.dart';
import 'package:eefood/features/meal_plan/presentation/widgets/update_item/meal_plan_ingredient_draft.dart';
import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';


class MealPlanIngredientsEditor extends StatelessWidget {
  final List<MealPlanIngredientDraft> drafts;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const MealPlanIngredientsEditor({
    super.key,
    required this.drafts,
    required this.onAdd,
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
    final borderColor = isDark
        ? colorScheme.onSurface.withValues(alpha: 0.14)
        : const Color(0xFFF6D7B8);
    final secondaryTextColor = isDark
        ? colorScheme.onSurface.withValues(alpha: 0.72)
        : Colors.brown.shade600;
    return ExpansionTile(
      initiallyExpanded: false,
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      title: Text(
        l10n.mealPlanIngredientsTitle,
        style: TextStyle(
          color: accentColor,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
      iconColor: accentColor,
      collapsedIconColor: accentColor,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onAdd,
            style: TextButton.styleFrom(
              foregroundColor: accentColor,
              backgroundColor: accentColor.withValues(alpha: 0.09),
            ),
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: Text(l10n.mealPlanAdd),
          ),
        ),
        if (drafts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              l10n.mealPlanNoIngredients,
              style: TextStyle(color: secondaryTextColor),
            ),
          )
        else
          ...List.generate(
            drafts.length,
            (index) => Padding(
              padding: const EdgeInsets.only(top: 6),
              child: IngredientEditorCard(
                draft: drafts[index],
                onRemove: () => onRemove(index),
              ),
            ),
          ),
      ],
    );
  }
}

