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

  // Tìm summary ứng với ngày đang chọn để UI có thể đọc nhanh mà không phải tự lọc list.
  MealPlanDailySummaryResponse? _findSummaryByDate(
    List<MealPlanDailySummaryResponse> summaries,
    DateTime? date,
  ) {
    for (final summary in summaries) {
      if (_sameDay(summary.planDate, date)) {
        return summary;
      }
    }
    return null;
  }

  // Cập nhật hoặc chèn thêm summary của một ngày sau khi item trong ngày đó thay đổi.
  List<MealPlanDailySummaryResponse> _mergeSummary(
    List<MealPlanDailySummaryResponse> summaries,
    MealPlanDailySummaryResponse updated,
  ) {
    var replaced = false;
    final next = summaries.map((summary) {
      if (_sameDay(summary.planDate, updated.planDate)) {
        replaced = true;
        return updated;
      }
      return summary;
    }).toList();

    if (!replaced) {
      next.add(updated);
      next.sort((a, b) {
        final left = a.planDate;
        final right = b.planDate;
        if (left == null && right == null) return 0;
        if (left == null) return 1;
        if (right == null) return -1;
        return left.compareTo(right);
      });
    }
    return next;
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

  // Load dữ liệu overview của màn Meal Plan:
  // - metadata plan hiện tại
  // - daily summary của tất cả ngày
  // Không load item list ở bước này để vào màn hình nhanh hơn.
  Future<void> loadOverview() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final results = await Future.wait<Object>([
        repository.getCurrentMealPlan(),
        repository.getDailySummary(),
      ]);

      final plan = results[0] as MealPlanResponse;
      final summaries = results[1] as List<MealPlanDailySummaryResponse>;

      DateTime? selectedDate;
      if (summaries.isNotEmpty) {
        selectedDate = summaries.first.planDate;
      } else {
        selectedDate = plan.startDate;
      }

      final selectedDaySummary = _findSummaryByDate(summaries, selectedDate);

      emit(
        state.copyWith(
          isLoading: false,
          plan: plan,
          dailySummaries: summaries,
          selectedDate: selectedDate,
          selectedDaySummary: selectedDaySummary,
          dayItems: const [],
          clearSelectedItem: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // Chỉ đổi ngày đang chọn trên UI.
  // Khi đổi ngày, xóa item cache của ngày cũ để buộc màn chi tiết ngày load lại đúng dữ liệu.
  void selectDate(DateTime date) {
    emit(
      state.copyWith(
        selectedDate: date,
        selectedDaySummary: _findSummaryByDate(state.dailySummaries, date),
        dayItems: const [],
        clearSelectedItem: true,
      ),
    );
  }

  // Load item của một ngày cụ thể.
  // Nếu không truyền date thì mặc định dùng selectedDate hiện tại trong state.
  Future<void> loadItemsByDate([DateTime? date]) async {
    final targetDate = date ?? state.selectedDate;
    if (targetDate == null) return;

    emit(
      state.copyWith(
        isLoadingItems: true,
        selectedDate: targetDate,
        selectedDaySummary: _findSummaryByDate(state.dailySummaries, targetDate),
        clearError: true,
      ),
    );
    try {
      final items = await repository.getMealPlanItemsByDate(targetDate);
      emit(
        state.copyWith(
          isLoadingItems: false,
          dayItems: items,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingItems: false, error: e.toString()));
    }
  }

  // Load chi tiết một item khi user mở item detail/bottom sheet.
  // Đồng thời cập nhật lại item đó trong dayItems để tránh dữ liệu cũ.
  Future<void> loadItemDetail(int id) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final item = await repository.getMealPlanItemDetail(id);
      emit(
        state.copyWith(
          isSubmitting: false,
          selectedItem: item,
          dayItems: _upsertItemInList(state.dayItems, item),
        ),
      );
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }

  // Refresh summary của đúng một ngày sau khi item trong ngày đó bị thêm/sửa/xóa.
  // Đây là granularity quan trọng để không phải reload toàn bộ plan.
  Future<void> refreshDailySummaryByDate([DateTime? date]) async {
    final targetDate = date ?? state.selectedDate;
    if (targetDate == null) return;

    try {
      final summary = await repository.getDailySummaryByDate(targetDate);
      final merged = _mergeSummary(state.dailySummaries, summary);
      emit(
        state.copyWith(
          dailySummaries: merged,
          selectedDaySummary: _findSummaryByDate(merged, targetDate),
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // Cập nhật metadata của meal plan hiện tại như goal, date range, note.
  Future<void> upsertMealPlan(MealPlanUpsertRequest request) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final plan = await repository.upsertMealPlan(request);
      emit(
        state.copyWith(
          isSubmitting: false,
          plan: plan,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }

  // Generate meal plan ban đầu.
  // Sau khi generate xong, load lại daily summary để overview phản ánh dữ liệu mới nhất.
  Future<void> generateMealPlan(MealPlanGenerateRequest request) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final plan = await repository.generateMealPlan(request);
      final summaries = await repository.getDailySummary();
      final selectedDate = summaries.isNotEmpty ? summaries.first.planDate : plan.startDate;
      emit(
        state.copyWith(
          isSubmitting: false,
          plan: plan,
          dailySummaries: summaries,
          selectedDate: selectedDate,
          selectedDaySummary: _findSummaryByDate(summaries, selectedDate),
          dayItems: const [],
          clearSelectedItem: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }

  // Sinh tiếp thêm ngày cho plan hiện tại rồi refresh lại phần overview.
  Future<void> continueMealPlan({int? days}) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final plan = await repository.continueMealPlan(days: days);
      final summaries = await repository.getDailySummary();
      final selectedDate = state.selectedDate ?? (summaries.isNotEmpty ? summaries.first.planDate : plan.startDate);
      emit(
        state.copyWith(
          isSubmitting: false,
          plan: plan,
          dailySummaries: summaries,
          selectedDate: selectedDate,
          selectedDaySummary: _findSummaryByDate(summaries, selectedDate),
        ),
      );
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }

  // Thêm mới hoặc cập nhật một item:
  // - cập nhật item local ngay để UI mượt
  // - sau đó refresh summary của đúng ngày liên quan
  Future<void> upsertMealPlanItem(MealPlanItemUpsertRequest request) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final item = await repository.upsertMealPlanItem(request);
      final targetDate = item.planDate ?? request.planDate ?? state.selectedDate;
      emit(
        state.copyWith(
          isSubmitting: false,
          selectedItem: item,
          selectedDate: targetDate ?? state.selectedDate,
          dayItems: _upsertItemInList(state.dayItems, item),
        ),
      );
      await refreshDailySummaryByDate(targetDate);
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }

  // Xóa item khỏi plan hiện tại:
  // - xóa item trong list local
  // - refresh summary ngày đang xem
  Future<void> deleteMealPlanItem(int id) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final plan = await repository.deleteMealPlanItem(id);
      final updatedItems = state.dayItems.where((item) => item.id != id).toList();
      emit(
        state.copyWith(
          isSubmitting: false,
          plan: plan,
          dayItems: updatedItems,
          clearSelectedItem: state.selectedItem?.id == id,
        ),
      );
      await refreshDailySummaryByDate();
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }
}
