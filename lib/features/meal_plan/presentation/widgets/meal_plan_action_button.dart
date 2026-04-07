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

  void _handleDeleteTap(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showCustomSnackBar(context, l10n.mealPlanDeleteNotSupported, isError: true);
  }

  Future<void> _openActions(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    await showCustomBottomSheet(context, [
      BottomSheetOption(
        icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey),
        title: l10n.mealPlanUpdateAction,
        onTap: () => _handleEditTap(context),
      ),
      BottomSheetOption(
        icon: const Icon(Icons.auto_awesome_outlined, color: Colors.orange),
        title: l10n.mealPlanCreateAi,
        onTap: () => _handleGenerateTap(context),
      ),
      BottomSheetOption(
        icon: const Icon(Icons.update_outlined, color: Colors.deepOrange),
        title: l10n.mealPlanContinueAction,
        onTap: () => _handleContinueTap(context),
      ),
      BottomSheetOption(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        title: l10n.mealPlanDeleteAction,
        onTap: () => _handleDeleteTap(context),
      ),
    ]);
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
