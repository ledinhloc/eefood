import 'package:dio/dio.dart';
import 'package:eefood/features/cook_process/data/models/ingredient_alter_response.dart';
import 'package:eefood/features/cook_process/domain/repositories/ingredient_alter_repository.dart';

class IngredientAlterRepositoryImpl extends IngredientAlterRepository {
  final Dio dio;
  IngredientAlterRepositoryImpl({required this.dio});

  @override
  Future<IngredientAlterModel?> getIngredientAlter(
    int recipeId,
    int ingredientId,
  ) async {
    try {
      final response = await dio.get(
        '/v1/recipes/$recipeId/ingredient-substitutes/$ingredientId',
      );

      final json = response.data;

      if (json == null || json['data'] == null) {
        return null;
      }

      return IngredientAlterModel.fromJson(json['data']);
    } catch (err) {
      throw Exception('Get failed ingredient substitute: $err');
    }
  }

  @override
  Future<void> selectAlterIngredient(
    int recipeId,
    int ingredientId,
    int substituteId,
  ) async {
    try {
      await dio.put(
        "/v1/recipes/$recipeId/ingredient-substitutes/$ingredientId",
        queryParameters: {'substituteId': substituteId},
      );
    } catch (err) {
      throw Exception('Put failed ingredient substitute: $err');
    }
  }
}
