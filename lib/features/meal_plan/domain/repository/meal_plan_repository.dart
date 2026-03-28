import 'package:eefood/features/meal_plan/data/model/meal_plan_daily_summary_response.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_generate_request.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_item_response.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_item_upsert_request.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_response.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_upsert_request.dart';

abstract class MealPlanRepository {
  Future<MealPlanResponse> getCurrentMealPlan();

  Future<List<MealPlanDailySummaryResponse>> getDailySummary();

  Future<MealPlanDailySummaryResponse> getDailySummaryByDate(DateTime date);

  Future<MealPlanResponse> upsertMealPlan(MealPlanUpsertRequest request);

  Future<MealPlanResponse> generateMealPlan(MealPlanGenerateRequest request);

  Future<MealPlanResponse> continueMealPlan({int? days});

  Future<MealPlanItemResponse> upsertMealPlanItem(
    MealPlanItemUpsertRequest request,
  );

  Future<List<MealPlanItemResponse>> getMealPlanItemsByDate(DateTime date);

  Future<MealPlanItemResponse> getMealPlanItemDetail(int id);

  Future<MealPlanResponse> deleteMealPlanItem(int id);
}
