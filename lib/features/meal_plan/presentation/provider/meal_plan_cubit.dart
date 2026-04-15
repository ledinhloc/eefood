import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/model/meal_plan_daily_summary_response.dart';
import '../../data/model/meal_plan_generate_request.dart';
import '../../data/model/meal_plan_item_response.dart';
import '../../data/model/meal_plan_item_upsert_request.dart';
import '../../data/model/meal_plan_response.dart';
import '../../data/model/meal_plan_upsert_request.dart';
import '../../domain/repository/meal_plan_repository.dart';
import 'meal_plan_state.dart';

class MealPlanCubit extends Cubit<MealPlanState> {
  final MealPlanRepository repository;

  MealPlanCubit({required this.repository}) : super(const MealPlanState());

  // So sánh theo "ngày" thay vì so sánh full DateTime để tránh lệch giờ/phút/giây.
  bool _sameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Upsert item vào list ngày hiện tại và sắp xếp lại theo meal slot rồi itemOrder.
  List<MealPlanItemResponse> _upsertItemInList(
    List<MealPlanItemResponse> items,
    MealPlanItemResponse item,
  ) {
    var replaced = false;
    final next = items.map((current) {
      if (current.id == item.id) {
        replaced = true;
        return item;
      }
      return current;
    }).toList();

    if (!replaced) {
      next.add(item);
    }

    next.sort((a, b) {
      final slotCompare = a.mealSlot.index.compareTo(b.mealSlot.index);
      if (slotCompare != 0) return slotCompare;
      return (a.itemOrder ?? 0).compareTo(b.itemOrder ?? 0);
    });
    return next;
  }

  List<DateTime> _buildHighlightedDates(DateTime? startDate, int? days) {
    if (startDate == null || days == null || days <= 0) return const [];
    return List.generate(
      days,
      (index) => DateTime(startDate.year, startDate.month, startDate.day + index),
    );
  }

  DateTime? _resolveInitialSelectedDate(
    List<MealPlanDailySummaryResponse> summaries,
    MealPlanResponse plan,
  ) {
    if (summaries.isEmpty) return plan.startDate;

    final today = DateTime.now();
    for (final summary in summaries) {
      if (_sameDay(summary.planDate, today)) {
        return summary.planDate;
      }
    }

    return summaries.first.planDate ?? plan.startDate;
  }

  // Load dữ liệu overview của màn Meal Plan:
  Future<void> loadOverview() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final results = await Future.wait<Object>([
        repository.getCurrentMealPlan(),
        repository.getDailySummary(),
      ]);

      final plan = results[0] as MealPlanResponse;
      final summaries = results[1] as List<MealPlanDailySummaryResponse>;
      final selectedDate = _resolveInitialSelectedDate(summaries, plan);

      emit(
        state.copyWith(
          isLoading: false,
          plan: plan,
          dailySummaries: summaries,
          selectedDate: selectedDate,
          dayItems: const [],
          highlightedDates: const [],
        ),
      );

      // if (selectedDate != null) {
      //   await loadItemsByDate(selectedDate);
      // }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // Khi đổi ngày, xóa item cache của ngày cũ để buộc màn chi tiết ngày load lại đúng dữ liệu.
  Future<void> toggleDate(DateTime date) async {
    if (_sameDay(state.selectedDate, date)) {
      emit(
        state.copyWith(
          clearSelectedDate: true,
          dayItems: const [],
          isLoadingItems: false,
        ),
      );
      return;
    }

    emit(state.copyWith(selectedDate: date, dayItems: const []));
    await loadItemsByDate(date);
  }

  // Load item của một ngày cụ thể.
  // Nếu không truyền date thì mặc định dùng selectedDate hiện tại trong state.
  Future<void> loadItemsByDate([DateTime? date]) async {
    final targetDate = date ?? state.selectedDate;
    if (targetDate == null) return;

    emit(state.copyWith(isLoadingItems: true, clearError: true));
    try {
      final items = await repository.getMealPlanItemsByDate(targetDate);
      emit(state.copyWith(isLoadingItems: false, dayItems: items));
    } catch (e) {
      emit(state.copyWith(isLoadingItems: false, error: e.toString()));
    }
  }

  // Load chi tiết một item khi user mở item detail/bottom sheet.
  Future<void> loadItemDetail(int id) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final item = await repository.getMealPlanItemDetail(id);
      emit(
        state.copyWith(
          isSubmitting: false,
          dayItems: _upsertItemInList(state.dayItems, item),
        ),
      );
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }

  // Refresh summary của đúng một ngày sau khi item trong ngày đó bị thêm/sửa/xóa.
  Future<void> refreshDailySummaryByDate([DateTime? _]) async {
    try {
      final summaries = await repository.getDailySummary();
      emit(state.copyWith(dailySummaries: summaries));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // Cập nhật metadata của meal plan hiện tại như goal, date range, note.
  Future<void> upsertMealPlan(MealPlanUpsertRequest request) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final plan = await repository.upsertMealPlan(request);
      emit(state.copyWith(isSubmitting: false, plan: plan));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }

  // Generate meal plan ban đầu.
  // Sau khi generate xong, load lại daily summary để overview phản ánh dữ liệu mới nhất.
  Future<bool> generateMealPlan(MealPlanGenerateRequest request) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final plan = await repository.generateMealPlan(request);
      final summaries = await repository.getDailySummary();
      final selectedDate = request.startDate ??
          (summaries.isNotEmpty ? summaries.first.planDate : plan.startDate);
      emit(
        state.copyWith(
          isSubmitting: false,
          plan: plan,
          dailySummaries: summaries,
          selectedDate: selectedDate,
          dayItems: const [],
          highlightedDates: _buildHighlightedDates(
            request.startDate ?? selectedDate,
            request.days,
          ),
        ),
      );
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          error: 'Chưa tạo được kế hoạch, vui lòng thử lại',
        ),
      );
      return false;
    }
  }

  // Sinh tiếp thêm ngày cho plan hiện tại rồi refresh lại phần overview.
  Future<void> continueMealPlan({
    required DateTime startDate,
    int? days,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final plan = await repository.continueMealPlan(
        startDate: startDate,
        days: days,
      );
      final summaries = await repository.getDailySummary();
      final selectedDate = startDate;
      emit(
        state.copyWith(
          isSubmitting: false,
          plan: plan,
          dailySummaries: summaries,
          selectedDate: selectedDate,
          dayItems: const [],
          highlightedDates: _buildHighlightedDates(startDate, days),
        ),
      );
      await loadItemsByDate(selectedDate);
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }

  // Thêm mới hoặc cập nhật một item:
  // - cập nhật item local ngay để UI mượt
  // - sau đó refresh summary của đúng ngày liên quan
  Future<void> upsertMealPlanItem(
    MealPlanItemUpsertRequest request, {
    bool showSubmittingState = true,
  }) async {
    emit(
      state.copyWith(
        isSubmitting: showSubmittingState ? true : state.isSubmitting,
        clearError: true,
      ),
    );
    try {
      final item = await repository.upsertMealPlanItem(request);
      final targetDate =
          item.planDate ?? request.planDate ?? state.selectedDate;
      final shouldPatchCurrentList = _sameDay(targetDate, state.selectedDate);
      emit(
        state.copyWith(
          isSubmitting: showSubmittingState ? false : state.isSubmitting,
          selectedDate: targetDate ?? state.selectedDate,
          dayItems: shouldPatchCurrentList
              ? _upsertItemInList(state.dayItems, item)
              : const [],
        ),
      );
      if (!shouldPatchCurrentList && targetDate != null) {
        await loadItemsByDate(targetDate);
      }
      await refreshDailySummaryByDate(targetDate);
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: showSubmittingState ? false : state.isSubmitting,
          error: e.toString(),
        ),
      );
    }
  }

  // Xóa item khỏi plan hiện tại:
  // - xóa item trong list local
  // - refresh summary ngày đang xem
  Future<void> deleteMealPlanItem(int id) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final plan = await repository.deleteMealPlanItem(id);
      final updatedItems = state.dayItems
          .where((item) => item.id != id)
          .toList();
      emit(
        state.copyWith(isSubmitting: false, plan: plan, dayItems: updatedItems),
      );
      await refreshDailySummaryByDate();
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }
}
