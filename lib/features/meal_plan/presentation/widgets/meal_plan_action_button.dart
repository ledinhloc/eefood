import 'package:eefood/core/widgets/custom_bottom_sheet.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/meal_plan/presentation/provider/meal_plan_cubit.dart';
import 'package:eefood/features/meal_plan/presentation/widgets/meal_plan_generate_sheet.dart';
import 'package:eefood/features/meal_plan/presentation/widgets/meal_plan_upsert_sheet.dart';
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
    final plan = context.read<MealPlanCubit>().state.plan;
    if (plan == null) {
      showCustomSnackBar(
        context,
        'Chua co meal plan de cap nhat',
        isError: true,
      );
      return;
    }

    await showMealPlanUpsertSheet(
      context: context,
      cubit: context.read<MealPlanCubit>(),
      plan: plan,
    );
  }

  void _handleDeleteTap(BuildContext context) {
    showCustomSnackBar(
      context,
      'Backend chua ho tro xoa meal plan',
      isError: true,
    );
  }

  Future<void> _openActions(BuildContext context) async {
    await showCustomBottomSheet(context, [
      BottomSheetOption(
        icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey),
        title: 'Cap nhat meal plan',
        onTap: () => _handleEditTap(context),
      ),
      BottomSheetOption(
        icon: const Icon(Icons.auto_awesome_outlined, color: Colors.orange),
        title: 'Tạo plan AI',
        onTap: () => _handleGenerateTap(context),
      ),
      BottomSheetOption(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        title: 'Xóa meal plan',
        onTap: () => _handleDeleteTap(context),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _openActions(context),
      icon: const Icon(Icons.more_horiz_rounded),
      tooltip: 'Thao tác meal plan',
    );
  }
}
