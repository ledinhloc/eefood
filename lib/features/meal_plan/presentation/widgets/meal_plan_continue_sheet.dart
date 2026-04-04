import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_response.dart';
import 'package:eefood/features/meal_plan/presentation/provider/meal_plan_cubit.dart';
import 'package:eefood/features/meal_plan/presentation/provider/meal_plan_state.dart';
import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

Future<void> showMealPlanContinueSheet({
  required BuildContext context,
  required MealPlanCubit cubit,
  required MealPlanResponse plan,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final today = DateTime.now();
  final normalizedToday = DateTime(today.year, today.month, today.day);
  final nextPlanDate = plan.endDate != null
      ? DateTime(plan.endDate!.year, plan.endDate!.month, plan.endDate!.day + 1)
      : normalizedToday;
  final initialDate = nextPlanDate.isAfter(normalizedToday)
      ? nextPlanDate
      : normalizedToday;
  final startDateController = TextEditingController(
    text: DateFormat('dd/MM/yyyy').format(initialDate),
  );
  final daysController = TextEditingController(text: '3');
  var selectedDate = initialDate;

  Future<void> pickStartDate(
    BuildContext context,
    TextEditingController controller,
    void Function(DateTime value) onPicked,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(initialDate.year - 1),
      lastDate: DateTime(initialDate.year + 2),
    );
    if (picked != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(picked);
      onPicked(picked);
    }
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.mealPlanContinueTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.mealPlanContinueSubtitle,
                    style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: startDateController,
                    readOnly: true,
                    onTap: () async {
                      await pickStartDate(
                        context,
                        startDateController,
                        (value) => setModalState(() => selectedDate = value),
                      );
                    },
                    decoration: InputDecoration(
                      labelText: l10n.mealPlanStartDate,
                      suffixIcon: const Icon(Icons.calendar_month_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: daysController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.mealPlanDays,
                      hintText: l10n.mealPlanDaysExample,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  BlocBuilder<MealPlanCubit, MealPlanState>(
                    bloc: cubit,
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE85D04),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: state.isSubmitting
                              ? null
                              : () async {
                                  final rawDays = int.tryParse(
                                    daysController.text.trim(),
                                  );
                                  if (rawDays == null || rawDays <= 0) {
                                    showCustomSnackBar(
                                      context,
                                      l10n.mealPlanInvalidDays,
                                      isError: true,
                                    );
                                    return;
                                  }

                                  await cubit.continueMealPlan(
                                    startDate: selectedDate,
                                    days: rawDays,
                                  );

                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                },
                          child: state.isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  l10n.mealPlanContinueButton,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
