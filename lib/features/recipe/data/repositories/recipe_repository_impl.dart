import 'package:dio/dio.dart';
import 'package:eefood/features/recipe/data/models/ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/region_model.dart';
import 'package:eefood/features/recipe/domain/repositories/recipe_repository.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final Dio dio;

  RecipeRepositoryImpl({required this.dio});

  @override
  Future<List<ProvinceModel>> getProvinces({
    String? keyword,
    int limit = 5,
    int page = 1,
  }) async {
    try {
      final response = await dio.get(
        'https://tinhthanhpho.com/api/v1/new-provinces',
        queryParameters: {
          if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
          'limit': limit,
          'page': page,
        },
      );

      final data = response.data;
      final list = (data is Map && data['data'] is List)
          ? data['data'] as List
          : (data is List ? data : []);
      return (list as List)
          .map((e) => ProvinceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (err) {
      print(err);
      throw Exception('Get province failed: $err');
    }
  }

  @override
  Future<List<WardModel>> getWard(
    String provinceCode, {
    String? keyword,
    int limit = 5,
    int page = 1,
  }) async {
    try {
      final response = await dio.get(
        'https://tinhthanhpho.com/api/v1/new-provinces/$provinceCode/wards',
        queryParameters: {
          if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
          'limit': limit,
          'page': page,
        },
      );

      final data = response.data;
      final list = (data is Map && data['data'] is List)
          ? data['data'] as List
          : (data is List ? data : []);
      return (list as List)
          .map(
            (e) => WardModel.fromJson(
              e as Map<String, dynamic>,
              provinceCode: provinceCode,
            ),
          )
          .toList();
    } catch (err) {
      print(err);
      throw Exception('Get ward failed: $err');
    }
  }

  @override
  Future<List<IngredientModel>> getAllIngredient(String name, int page, int limit) async {
    try {
      final response = await dio.get(
        '/v1/ingredients',
        queryParameters: {
          'name': name,
          'page': page,
          'limit': limit,
        },
      );

      final data = response.data;
      if (data != null && data['data'] != null) {
        final content = data['data']['content'] as List<dynamic>;
        return content
            .map(
              (json) => IngredientModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }

      return List.empty();
    } catch (err) {
      print(err);
      throw Exception('Get ingredients failed: $err');
    }
  }
}
