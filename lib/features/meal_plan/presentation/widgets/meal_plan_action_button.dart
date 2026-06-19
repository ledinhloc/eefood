import 'package:eefood/core/widgets/custom_bottom_sheet.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/meal_plan/presentation/provider/meal_plan_cubit.dart';
import 'package:eefood/features/meal_plan/presentation/widgets/meal_plan_continue_sheet.dart';
import 'package:eefood/features/meal_plan/presentation/widgets/meal_plan_generate_sheet.dart';
import 'package:eefood/features/meal_plan/presentation/widgets/meal_plan_upsert_sheet.dart';
import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MealPlanActionButton extends StatelessWidget {
  const MealPlanActionButton({super.key});

  Future<void> _handleGenerateTap(BuildContext context) async {
    await showMealPlanGenerateSheet(
      context: context,
      cubit: context.read<MealPlanCubit>(),
    );
  }

  Future<void> _handleEditTap(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final plan = context.read<MealPlanCubit>().state.plan;
    if (plan == null) {
      showCustomSnackBar(context, l10n.mealPlanNoPlanToUpdate, isError: true);
      return;
    }

    await showMealPlanUpsertSheet(
      context: context,
      cubit: context.read<MealPlanCubit>(),
      plan: plan,
    );
  }

  Future<void> _handleContinueTap(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<MealPlanCubit>();
    final plan = cubit.state.plan;
    if (plan == null) {
      showCustomSnackBar(context, l10n.mealPlanNoPlanToContinue, isError: true);
      return;
    }

    await showMealPlanContinueSheet(context: context, cubit: cubit, plan: plan);
  }

  Future<void> _handleDeleteTap(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colorScheme = theme.colorScheme;
        final errorColor = colorScheme.error;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: errorColor.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: errorColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.mealPlanDeleteAction,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.mealPlanDeleteConfirmMessage,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          side: BorderSide(color: colorScheme.outlineVariant),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: errorColor,
                          foregroundColor: colorScheme.onError,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(l10n.mealPlanDeleteAction),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    final success = await context.read<MealPlanCubit>().deleteCurrentMealPlan();
    if (!context.mounted || !success) return;

    showCustomSnackBar(context, l10n.mealPlanDeleteSuccess);
  }

  Future<void> _openActions(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final hasPlan = context.read<MealPlanCubit>().state.plan != null;
    await showCustomBottomSheet(
      context,
      hasPlan
          ? [
              BottomSheetOption(
                icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey),
                title: l10n.mealPlanUpdateAction,
                onTap: () => _handleEditTap(context),
              ),
              BottomSheetOption(
                icon: const Icon(
                  Icons.update_outlined,
                  color: Colors.deepOrange,
                ),
                title: l10n.mealPlanContinueAction,
                onTap: () => _handleContinueTap(context),
              ),
              BottomSheetOption(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                title: l10n.mealPlanDeleteAction,
                onTap: () => _handleDeleteTap(context),
              ),
            ]
          : [
              BottomSheetOption(
                icon: const Icon(
                  Icons.auto_awesome_outlined,
                  color: Colors.orange,
                ),
                title: l10n.mealPlanCreateAi,
                onTap: () => _handleGenerateTap(context),
              ),
            ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _openActions(context),
      icon: const Icon(Icons.more_horiz_rounded),
      tooltip: AppLocalizations.of(context)!.mealPlanActionTooltip,
    );
  }
}
