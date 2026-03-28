import 'package:dio/dio.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_daily_summary_response.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_generate_request.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_item_response.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_item_upsert_request.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_response.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_upsert_request.dart';
import 'package:eefood/features/meal_plan/domain/repository/meal_plan_repository.dart';

class MealPlanRepositoryImpl implements MealPlanRepository {
  final Dio dio;

  MealPlanRepositoryImpl({required this.dio});

  String _localDate(DateTime date) => date.toIso8601String().split('T').first;

  @override
  Future<MealPlanResponse> getCurrentMealPlan() async {
    try {
      final response = await dio.get('/v1/meal-plan');
      return MealPlanResponse.fromJson(response.data['data']);
    } catch (err) {
      throw Exception('Get current meal plan failed: $err');
    }
  }

  @override
  Future<List<MealPlanDailySummaryResponse>> getDailySummary() async {
    try {
      final response = await dio.get('/v1/meal-plan/daily-summary');
      final data = (response.data['data'] as List<dynamic>?) ?? [];
      return data
          .map(
            (e) => MealPlanDailySummaryResponse.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (err) {
      throw Exception('Get meal plan daily summary failed: $err');
    }
  }

  @override
  Future<MealPlanDailySummaryResponse> getDailySummaryByDate(
    DateTime date,
  ) async {
    try {
      final response = await dio.get(
        '/v1/meal-plan/daily-summary/by-date',
        queryParameters: {'date': _localDate(date)},
      );
      return MealPlanDailySummaryResponse.fromJson(response.data['data']);
    } catch (err) {
      throw Exception('Get meal plan daily summary by date failed: $err');
    }
  }

  @override
  Future<MealPlanResponse> upsertMealPlan(MealPlanUpsertRequest request) async {
    try {
      final response = await dio.put(
        '/v1/meal-plan',
        data: request.toJson(),
        options: Options(contentType: 'application/json'),
      );
      return MealPlanResponse.fromJson(response.data['data']);
    } catch (err) {
      throw Exception('Upsert meal plan failed: $err');
    }
  }

  @override
  Future<MealPlanResponse> generateMealPlan(
    MealPlanGenerateRequest request,
  ) async {
    try {
      final response = await dio.post(
        '/v1/meal-plan/generate',
        data: request.toJson(),
        options: Options(contentType: 'application/json'),
      );
      return MealPlanResponse.fromJson(response.data['data']);
    } catch (err) {
      throw Exception('Generate meal plan failed: $err');
    }
  }

  @override
  Future<MealPlanResponse> continueMealPlan({int? days}) async {
    try {
      final response = await dio.post(
        '/v1/meal-plan/continue',
        queryParameters: {
          if (days != null) 'days': days,
        },
      );
      return MealPlanResponse.fromJson(response.data['data']);
    } catch (err) {
      throw Exception('Continue meal plan failed: $err');
    }
  }

  @override
  Future<MealPlanItemResponse> upsertMealPlanItem(
    MealPlanItemUpsertRequest request,
  ) async {
    try {
      final response = await dio.put(
        '/v1/meal-plan/items',
        data: request.toJson(),
        options: Options(contentType: 'application/json'),
      );
      return MealPlanItemResponse.fromJson(response.data['data']);
    } catch (err) {
      throw Exception('Upsert meal plan item failed: $err');
    }
  }

  @override
  Future<List<MealPlanItemResponse>> getMealPlanItemsByDate(
    DateTime date,
  ) async {
    try {
      final response = await dio.get(
        '/v1/meal-plan/items',
        queryParameters: {'date': _localDate(date)},
      );
      final data = (response.data['data'] as List<dynamic>?) ?? [];
      return data
          .map((e) => MealPlanItemResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (err) {
      throw Exception('Get meal plan items by date failed: $err');
    }
  }

  @override
  Future<MealPlanItemResponse> getMealPlanItemDetail(int id) async {
    try {
      final response = await dio.get('/v1/meal-plan/items/$id');
      return MealPlanItemResponse.fromJson(response.data['data']);
    } catch (err) {
      throw Exception('Get meal plan item detail failed: $err');
    }
  }

  @override
  Future<MealPlanResponse> deleteMealPlanItem(int id) async {
    try {
      final response = await dio.delete('/v1/meal-plan/items/$id');
      return MealPlanResponse.fromJson(response.data['data']);
    } catch (err) {
      throw Exception('Delete meal plan item failed: $err');
    }
  }
}
