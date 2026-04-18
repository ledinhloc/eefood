import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum MealPlanItemStatus {
  @JsonValue('PLANNED')
  planned('PLANNED'),

  @JsonValue('DONE')
  done('DONE'),

  @JsonValue('SKIPPED')
  skipped('SKIPPED');

  const MealPlanItemStatus(this.value);

  final String value;
}

extension MealPlanItemStatusX on MealPlanItemStatus {
  String get label {
    switch (this) {
      case MealPlanItemStatus.planned:
        return 'Đã lên kế hoạch';
      case MealPlanItemStatus.done:
        return 'Đã ăn';
      case MealPlanItemStatus.skipped:
        return 'Đã bỏ qua';
    }
  }

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

  Color backgroundColor(bool isDark) {
    switch (this) {
      case MealPlanItemStatus.planned:
        return isDark ? const Color(0xFF4E3A22) : const Color(0xFFF6E7D3);
      case MealPlanItemStatus.done:
        return isDark ? const Color(0xFF1F4632) : const Color(0xFFDDF3E4);
      case MealPlanItemStatus.skipped:
        return isDark ? const Color(0xFF4A2630) : const Color(0xFFF8DDE3);
    }
  }

  Color textColor(bool isDark) {
    switch (this) {
      case MealPlanItemStatus.planned:
        return isDark ? const Color(0xFFFFD08A) : const Color(0xFF9A5A00);
      case MealPlanItemStatus.done:
        return isDark ? const Color(0xFF98E0B0) : const Color(0xFF2E7D4F);
      case MealPlanItemStatus.skipped:
        return isDark ? const Color(0xFFFFB3C1) : const Color(0xFFC2556E);
    }
  }

  Color borderColor(bool isDark) {
    switch (this) {
      case MealPlanItemStatus.planned:
        return isDark ? const Color(0xFF7A5A35) : const Color(0xFFE7CDAA);
      case MealPlanItemStatus.done:
        return isDark ? const Color(0xFF386B4E) : const Color(0xFFB9E2C6);
      case MealPlanItemStatus.skipped:
        return isDark ? const Color(0xFF7D4250) : const Color(0xFFF0BAC6);
    }
  }
}
