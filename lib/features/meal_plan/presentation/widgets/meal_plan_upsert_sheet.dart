import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_response.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_upsert_request.dart';
import 'package:eefood/features/meal_plan/presentation/provider/meal_plan_cubit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<void> showMealPlanUpsertSheet({
  required BuildContext context,
  required MealPlanCubit cubit,
  required MealPlanResponse plan,
  Future<void> Function()? onSuccess,
}) async {
  final goalController = TextEditingController(text: plan.goal ?? '');
  final startDateController = TextEditingController(
    text: _formatDate(plan.startDate),
  );
  final endDateController = TextEditingController(
    text: _formatDate(plan.endDate),
  );
  final noteController = TextEditingController(text: plan.note ?? '');
  final userHealthNoteController = TextEditingController(
    text: plan.userHealthNote ?? '',
  );

  DateTime? selectedStartDate = plan.startDate;
  DateTime? selectedEndDate = plan.endDate;

  Future<void> pickDate({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required TextEditingController controller,
    required void Function(DateTime value) onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      controller.text = _formatDate(picked);
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
            final now = DateTime.now();
            final initialStartDate = selectedStartDate ?? plan.startDate ?? now;
            final initialEndDate =
                selectedEndDate ?? selectedStartDate ?? plan.endDate ?? now;

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: SingleChildScrollView(
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
                      'Cap nhat meal plan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: goalController,
                      decoration: InputDecoration(
                        labelText: 'Muc tieu',
                        hintText: 'Vi du: An can bang, tang co, giam can',
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
                        await pickDate(
                          context: context,
                          initialDate: initialStartDate,
                          firstDate: DateTime(now.year - 1),
                          lastDate: DateTime(now.year + 2),
                          controller: startDateController,
                          onPicked: (value) {
                            setModalState(() {
                              selectedStartDate = value;
                              if (selectedEndDate != null &&
                                  selectedEndDate!.isBefore(value)) {
                                selectedEndDate = value;
                                endDateController.text = _formatDate(value);
                              }
                            });
                          },
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
                      controller: endDateController,
                      readOnly: true,
                      onTap: () async {
                        await pickDate(
                          context: context,
                          initialDate: initialEndDate,
                          firstDate: selectedStartDate ?? DateTime(now.year - 1),
                          lastDate: DateTime(now.year + 2),
                          controller: endDateController,
                          onPicked: (value) {
                            setModalState(() => selectedEndDate = value);
                          },
                        );
                      },
                      decoration: InputDecoration(
                        labelText: 'Ngay ket thuc',
                        suffixIcon: const Icon(Icons.event_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: noteController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Ghi chu',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: userHealthNoteController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Ghi chu suc khoe',
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
                          if (selectedStartDate != null &&
                              selectedEndDate != null &&
                              selectedEndDate!.isBefore(selectedStartDate!)) {
                            showCustomSnackBar(
                              context,
                              'Ngay ket thuc phai lon hon hoac bang ngay bat dau',
                              isError: true,
                            );
                            return;
                          }

                          final goal = goalController.text.trim();
                          final note = noteController.text.trim();
                          final userHealthNote =
                              userHealthNoteController.text.trim();

                          await cubit.upsertMealPlan(
                            MealPlanUpsertRequest(
                              goal: goal.isEmpty ? null : goal,
                              startDate: selectedStartDate,
                              endDate: selectedEndDate,
                              note: note.isEmpty ? null : note,
                              userHealthNote: userHealthNote.isEmpty
                                  ? null
                                  : userHealthNote,
                            ),
                          );

                          if (!context.mounted) return;
                          Navigator.pop(context);
                          await onSuccess?.call();
                        },
                        child: const Text(
                          'Luu cap nhat',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

String _formatDate(DateTime? date) {
  if (date == null) return '';
  return DateFormat('dd/MM/yyyy').format(date);
}
