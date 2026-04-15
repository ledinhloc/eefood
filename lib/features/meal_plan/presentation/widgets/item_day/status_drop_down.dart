import 'package:eefood/features/meal_plan/domain/enum/meal_plan_item_status.dart';
import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class StatusDropdown extends StatelessWidget {
  final MealPlanItemStatus value;
  final bool isBusy;
  final Color textColor;
  final Color borderColor;
  final Color fillColor;
  final ValueChanged<MealPlanItemStatus?> onChanged;

  const StatusDropdown({
    super.key,
    required this.value,
    required this.isBusy,
    required this.textColor,
    required this.borderColor,
    required this.fillColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final menuTextColor = theme.colorScheme.onSurface;

    return SizedBox(
      width: 150,
      height: 36,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<MealPlanItemStatus>(
                value: value,
                isDense: true,
                isExpanded: true,
                borderRadius: BorderRadius.circular(18),
                icon: isBusy
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(textColor),
                        ),
                      )
                    : Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: textColor,
                        size: 20,
                      ),
                style: TextStyle(
                  color: menuTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                dropdownColor: Theme.of(context).colorScheme.surface,
                selectedItemBuilder: (context) => MealPlanItemStatus.values
                    .map(
                      (status) => Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          status.localizedLabel(l10n),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: status.textColor(isDark),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                items: MealPlanItemStatus.values
                    .map(
                      (status) => DropdownMenuItem<MealPlanItemStatus>(
                        value: status,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: status.backgroundColor(isDark),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status.localizedLabel(l10n),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: status.textColor(isDark),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: isBusy ? null : onChanged,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
