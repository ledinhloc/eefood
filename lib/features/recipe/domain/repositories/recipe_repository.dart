import 'package:eefood/features/auth/data/models/result_model.dart';
import 'package:eefood/features/recipe/data/models/category_model.dart';
import 'package:eefood/features/recipe/data/models/ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:eefood/features/recipe/data/models/region_model.dart';
import 'package:eefood/features/recipe/domain/entities/recipe.dart';

abstract class RecipeRepository {
  Future<List<ProvinceModel>> getProvinces({String? keyword, int limit = 5, int page = 1});
  Future<List<WardModel>> getWard(String provinceCode, {String? keyword, int limit = 5, int page = 1});
  Future<List<IngredientModel>> getAllIngredient(String? name, int page, int limit);
  Future<List<CategoryModel>> getAllCategories(String? name, int page, int limitt);
  Future<Result<RecipeModel>> createRecipe(RecipeModel recipe);
}