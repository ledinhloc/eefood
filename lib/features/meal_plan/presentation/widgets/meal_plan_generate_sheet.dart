import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_generate_request.dart';
import 'package:eefood/features/meal_plan/presentation/provider/meal_plan_cubit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<void> showMealPlanGenerateSheet({
  required BuildContext context,
  required MealPlanCubit cubit,
  required Future<void> Function() onSuccess,
}) async {
  final goalController = TextEditingController();
  final startDateController = TextEditingController(
    text: DateFormat('dd/MM/yyyy').format(DateTime.now()),
  );
  final daysController = TextEditingController(text: '3');

  DateTime selectedDate = DateTime.now();

  Future<void> pickStartDate(
    BuildContext context,
    TextEditingController controller,
    void Function(DateTime value) onPicked,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
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
                  const Text(
                    'Tao plan AI',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nhap muc tieu, ngay bat dau va so ngay de AI tao ke hoach bua an.',
                    style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: goalController,
                    decoration: InputDecoration(
                      labelText: 'Goal',
                      hintText: 'Vi du: Giam can, an can bang, tang co...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
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
                      labelText: 'Ngay bat dau',
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
                      labelText: 'So ngay',
                      hintText: 'Toi da 5 ngay moi lan tao',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
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
                      onPressed: () async {
                        final rawGoal = goalController.text.trim();
                        final rawDays = int.tryParse(daysController.text.trim());

                        if (rawGoal.isEmpty || rawDays == null || rawDays <= 0) {
                          showCustomSnackBar(
                            context,
                            'Vui long nhap day du thong tin hop le',
                            isError: true,
                          );
                          return;
                        }

                        final success = await cubit.generateMealPlan(
                          MealPlanGenerateRequest(
                            goal: rawGoal,
                            startDate: selectedDate,
                            days: rawDays,
                          ),
                        );

                        if (!context.mounted) return;
                        if (success) {
                          Navigator.pop(context);
                          await onSuccess();
                        }
                      },
                      child: const Text(
                        'Tao ke hoach',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
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
