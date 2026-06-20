import 'package:eefood/features/meal_plan/presentation/provider/meal_plan_cubit.dart';
import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

Future<bool?> showMealPlanRegenerateSheet({
  required BuildContext context,
  required MealPlanCubit cubit,
  required List<int> itemIds,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          12,
          12,
          12,
          MediaQuery.viewInsetsOf(sheetContext).bottom + 12,
        ),
        child: _MealPlanRegenerateSheet(cubit: cubit, itemIds: itemIds),
      );
    },
  );
}

class _MealPlanRegenerateSheet extends StatefulWidget {
  final MealPlanCubit cubit;
  final List<int> itemIds;

  const _MealPlanRegenerateSheet({required this.cubit, required this.itemIds});

  @override
  State<_MealPlanRegenerateSheet> createState() =>
      _MealPlanRegenerateSheetState();
}

class _MealPlanRegenerateSheetState extends State<_MealPlanRegenerateSheet> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
    });

    final success = await widget.cubit.regenerateMealPlanItems(
      widget.itemIds,
      reason: _reasonController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
      return;
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? colorScheme.primary : const Color(0xFFE85D04);
    final fieldColor = isDark
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.45)
        : const Color(0xFFF7F7F7);
    final borderColor = colorScheme.onSurface.withValues(
      alpha: isDark ? 0.16 : 0.08,
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.82,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.mealPlanRegenerateTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.mealPlanRegenerateReasonHint,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.pop(context),
                    tooltip: l10n.cancel,
                    style: IconButton.styleFrom(
                      backgroundColor: fieldColor,
                      minimumSize: const Size(40, 40),
                    ),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: isDark ? 0.14 : 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.people_alt_outlined,
                      size: 20,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.mealPlanSelectedItems(widget.itemIds.length),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.mealPlanRegenerateReason,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonController,
                minLines: 3,
                maxLines: 5,
                maxLength: 500,
                enabled: !_isSubmitting,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: l10n.mealPlanRegenerateReasonHint,
                  filled: true,
                  fillColor: fieldColor,
                  contentPadding: const EdgeInsets.all(14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primaryColor, width: 1.5),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: borderColor),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.auto_awesome_rounded),
                  label: Text(
                    _isSubmitting
                        ? l10n.mealPlanRegenerating
                        : l10n.mealPlanRegenerateAction,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: isDark
                        ? colorScheme.onPrimary
                        : Colors.white,
                    disabledBackgroundColor: primaryColor.withValues(
                      alpha: 0.55,
                    ),
                    disabledForegroundColor: isDark
                        ? colorScheme.onPrimary
                        : Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
