import 'package:eefood/l10n/app_localizations.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum MealSlot {
  @JsonValue('BREAKFAST')
  breakfast('BREAKFAST'),

  @JsonValue('LUNCH')
  lunch('LUNCH'),

  @JsonValue('DINNER')
  dinner('DINNER'),

  @JsonValue('SNACK')
  snack('SNACK');

  const MealSlot(this.value);

  final String value;
}

extension MealSlotX on MealSlot {
  String get label {
    switch (this) {
      case MealSlot.breakfast:
        return 'Bữa sáng';
      case MealSlot.lunch:
        return 'Bữa trưa';
      case MealSlot.dinner:
        return 'Bữa tối';
      case MealSlot.snack:
        return 'Bữa phụ';
    }
  }

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
