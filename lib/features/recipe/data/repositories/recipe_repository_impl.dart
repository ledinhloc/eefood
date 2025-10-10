import 'package:dio/dio.dart';
import 'package:eefood/features/auth/data/models/result_model.dart';
import 'package:eefood/features/recipe/data/models/category_model.dart';
import 'package:eefood/features/recipe/data/models/ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:eefood/features/recipe/data/models/region_model.dart';
import 'package:eefood/features/recipe/domain/entities/recipe.dart';
import 'package:eefood/features/recipe/domain/repositories/recipe_repository.dart';
import 'package:flutter/foundation.dart';

import '../models/recipe_detail_model.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final Dio dio;

  RecipeRepositoryImpl({required this.dio});
  @override
  Future<RecipeDetailModel> fetchRecipeDetail(int recipeId) async {
    try {
      final response = await dio.get(
        '/v1/recipes/detail/$recipeId',
        options: Options(contentType: 'application/json'),
      );

      final Map<String, dynamic> responseData = response.data;

      if (responseData.containsKey('data')) {
        final recipeRes = RecipeDetailModel.fromJson(responseData['data']);
        return recipeRes;
      } else {
        throw Exception('Invalid response format: missing data field');
      }
    } catch (err) {
      throw Exception('Get recipe failed: $err');
    }
  }

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
  Future<List<IngredientModel>> getAllIngredient(
    String? name,
    int page,
    int limit,
  ) async {
    try {
      final response = await dio.get(
        '/v1/ingredients',
        queryParameters: {'name': name, 'page': page, 'limit': limit},
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

  @override
  Future<Result<RecipeModel>> createRecipe(RecipeModel request) async {
    print(request.toJson());
    try {
      final response = await dio.post(
        '/v1/recipes',
        data: request.toJson(),
        options: Options(contentType: 'application/json'),
      );

      final recipeRes = RecipeModel.fromJson(response.data['data']);
      print(recipeRes);
      return Result.success(recipeRes);
    } catch (err) {
      print(err);
      throw Exception('Create recipe failed: $err');
    }
  }

  @override
  Future<List<CategoryModel>> getAllCategories(
    String? name,
    int page,
    int limit,
  ) async {
    try {
      final response = await dio.get(
        '/v1/categories',
        queryParameters: {'name': name, 'page': page, 'limit': limit},
        options: Options(contentType: 'application/json'),
      );

      final data = response.data;
      if (data != null && data['data'] != null) {
        final content = data['data']['content'] as List<dynamic>;
        return content
            .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return List.empty();
    } catch (err) {
      print(err);
      throw Exception('Get categories failed: $err');
    }
  }

  @override
  Future<Result<List<RecipeModel>>> getMyRecipe(
    String? title,
    String? description,
    String? region,
    String? difficulty,
    int? categoryId,
    int page,
    int size,
    String sortBy,
    String direction,
  ) async {
    try {
      final response = await dio.get(
        '/v1/recipes/my',
        queryParameters: {
          if (title != null && title.isNotEmpty) 'title': title,
          if (description != null && description.isNotEmpty)
            'description': description,
          if (region != null && region.isNotEmpty) 'region': region,
          if (difficulty != null && difficulty.isNotEmpty)
            'difficulty': difficulty,
          if (categoryId != null) 'categoryId': categoryId,
          'page': page,
          'size': size,
          'sortBy': sortBy,
          'direction': direction,
        },
        options: Options(contentType: 'application/json'),
      );
      final data = response.data;
      if (data != null && data['data'] != null) {
        // API trả về Page<RecipeResponse> trong data
        final content = data['data']['content'] as List<dynamic>;
        final listRecipe = content
            .map((json) => RecipeModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return Result.success(listRecipe);
      }
      return Result.success(List.empty());
    } catch (err) {
      debugPrint('Get my recipes error: $err');
      throw Exception('Get my recipes failed: $err');
    }
  }

  @override
  Future<Result<RecipeModel>> updateRecipe(int id, RecipeModel request) async {
    try {
      final response = await dio.put(
        '/v1/recipes/$id',
        data: request.toJson(),
        options: Options(contentType: 'application/json'),
      );

      final Map<String, dynamic> responseData = response.data;

      // Kiểm tra cấu trúc response và đảm bảo lấy đúng dữ liệu
      if (responseData.containsKey('data')) {
        final recipeRes = RecipeModel.fromJson(responseData['data']);

        if (recipeRes.ingredients?.length != request.ingredients?.length) {
          recipeRes.ingredients = request.ingredients;
        }
      
        return Result.success(recipeRes);
      } else {
        throw Exception('Invalid response format: missing data field');
      }
    } catch (err) {
      debugPrint('Update recipe error: $err');
      throw Exception('Update recipe failed: $err');
    }
  }

  @override
  Future<Result<String>> deleteRecipe(int id) async {
    try {
      final response = await dio.delete(
        '/v1/recipes/$id',
        options: Options(contentType: 'application/json'),
      );

      final Map<String, dynamic> data = response.data;
      final String message = data['message']?.toString() ?? "Unknown response";

      if (data['status'] == 200) {
        return Result.success(message);
      }
      return Result.failure(message);
    } catch (err) {
      debugPrint('Delete recipe error: $err');
      throw Exception('Delete recipe failed: $err');
    }
  }

  @override
  Future<RecipeModel> getRecipeById(int recipeId) async {
    try {
      final response = await dio.get(
        '/v1/recipes/$recipeId',
        options: Options(contentType: 'application/json'),
      );

      final Map<String, dynamic> responseData = response.data;

      if (responseData.containsKey('data')) {
        final recipeRes = RecipeModel.fromJson(responseData['data']);
        return recipeRes;
      } else {
        throw Exception('Invalid response format: missing data field');
      }
    } catch (err) {
      throw Exception('Get recipe failed: $err');
    }
  }
}
