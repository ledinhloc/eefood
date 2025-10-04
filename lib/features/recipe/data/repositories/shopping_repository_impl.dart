import 'package:dio/dio.dart';
import '../models/shopping_item_model.dart';
import '../models/shopping_ingredient_model.dart';
import '../../domain/repositories/shopping_repository.dart';

class ShoppingRepositoryImpl implements ShoppingRepository {
  final Dio dio;
  ShoppingRepositoryImpl({required this.dio});

  @override
  Future<List<ShoppingItemModel>> getByRecipe() async {
    final resp = await dio.get('/v1/shopping/by-recipe');
    final data = (resp.data['data'] as List<dynamic>?) ?? [];
    return data.map((e) => ShoppingItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ShoppingIngredientModel>> getByIngredient() async {
    final resp = await dio.get('/v1/shopping/by-ingredient');
    final data = (resp.data['data'] as List<dynamic>?) ?? [];
    return data.map((e) => ShoppingIngredientModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> addRecipe(int recipeId, {int servings = 1}) async {
    await dio.post('/v1/shopping/add', queryParameters: {'recipeId': recipeId, 'servings': servings});
  }

  @override
  Future<void> removeItem(int itemId) async {
    await dio.delete('/v1/shopping/$itemId');
  }

  @override
  Future<void> updateServings(int itemId, int servings) async {
    await dio.put('/v1/shopping/$itemId/servings', queryParameters: {'servings': servings});
  }

  @override
  Future<void> togglePurchased(List<int> ingredientIds, bool purchased) async {
    await dio.put('/v1/shopping/ingredient/purchased', queryParameters: {'ingredientIds': ingredientIds, 'purchased': purchased});
  }
}
