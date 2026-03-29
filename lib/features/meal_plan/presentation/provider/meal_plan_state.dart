import 'package:eefood/features/meal_plan/data/model/meal_plan_daily_summary_response.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_item_response.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_response.dart';

class MealPlanState {
  final bool isLoading;
  final bool isLoadingItems;
  final bool isSubmitting;
  final MealPlanResponse? plan;
  final List<MealPlanDailySummaryResponse> dailySummaries;
  final DateTime? selectedDate;
  final MealPlanDailySummaryResponse? selectedDaySummary;
  final List<MealPlanItemResponse> dayItems;
  final MealPlanItemResponse? selectedItem;
  final List<DateTime> highlightedDates;
  final String? error;

  const MealPlanState({
    this.isLoading = false,
    this.isLoadingItems = false,
    this.isSubmitting = false,
    this.plan,
    this.dailySummaries = const [],
    this.selectedDate,
    this.selectedDaySummary,
    this.dayItems = const [],
    this.selectedItem,
    this.highlightedDates = const [],
    this.error,
  });

  MealPlanState copyWith({
    bool? isLoading,
    bool? isLoadingItems,
    bool? isSubmitting,
    MealPlanResponse? plan,
    List<MealPlanDailySummaryResponse>? dailySummaries,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
    MealPlanDailySummaryResponse? selectedDaySummary,
    bool clearSelectedDaySummary = false,
    List<MealPlanItemResponse>? dayItems,
    MealPlanItemResponse? selectedItem,
    bool clearSelectedItem = false,
    List<DateTime>? highlightedDates,
    String? error,
    bool clearError = false,
  }) {
    return MealPlanState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingItems: isLoadingItems ?? this.isLoadingItems,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      plan: plan ?? this.plan,
      dailySummaries: dailySummaries ?? this.dailySummaries,
      selectedDate: clearSelectedDate
          ? null
          : (selectedDate ?? this.selectedDate),
      selectedDaySummary: clearSelectedDaySummary
          ? null
          : (selectedDaySummary ?? this.selectedDaySummary),
      dayItems: dayItems ?? this.dayItems,
      selectedItem: clearSelectedItem
          ? null
          : (selectedItem ?? this.selectedItem),
      highlightedDates: highlightedDates ?? this.highlightedDates,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
