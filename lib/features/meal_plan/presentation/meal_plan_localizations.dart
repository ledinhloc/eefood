import 'package:eefood/features/meal_plan/domain/enum/meal_plan_item_status.dart';
import 'package:eefood/features/meal_plan/domain/enum/meal_slot.dart';
import 'package:eefood/l10n/app_localizations.dart';

extension MealSlotLocalizationX on MealSlot {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case MealSlot.breakfast:
        return l10n.mealPlanMealSlotBreakfast;
      case MealSlot.lunch:
        return l10n.mealPlanMealSlotLunch;
      case MealSlot.dinner:
        return l10n.mealPlanMealSlotDinner;
      case MealSlot.snack:
        return l10n.mealPlanMealSlotSnack;
    }
  }
}

extension MealPlanItemStatusLocalizationX on MealPlanItemStatus {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case MealPlanItemStatus.planned:
        return l10n.mealPlanStatusPlanned;
      case MealPlanItemStatus.done:
        return l10n.mealPlanStatusDone;
      case MealPlanItemStatus.skipped:
        return l10n.mealPlanStatusSkipped;
    }
  }
}
