import 'package:eefood/features/recipe/data/models/region_model.dart';

abstract class RecipeRepository {
  Future<List<ProvinceModel>> getProvinces({String? keyword, int limit = 5, int page = 1});
  Future<List<WardModel>> getWard(String provinceCode, {String? keyword, int limit = 5, int page = 1});
}