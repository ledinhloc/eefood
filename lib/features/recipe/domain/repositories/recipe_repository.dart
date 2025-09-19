import 'package:eefood/features/recipe/data/models/ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/region_model.dart';

abstract class RecipeRepository {
  Future<List<ProvinceModel>> getProvinces({String? keyword, int limit = 5, int page = 1});
  Future<List<WardModel>> getWard(String provinceCode, {String? keyword, int limit = 5, int page = 1});
  Future<List<IngredientModel>> getAllIngredient(String name, int page, int limit);
}