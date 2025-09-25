import 'package:eefood/features/auth/data/models/result_model.dart';
import 'package:eefood/features/recipe/data/models/category_model.dart';
import 'package:eefood/features/recipe/data/models/ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:eefood/features/recipe/data/models/region_model.dart';
import 'package:eefood/features/recipe/domain/entities/recipe.dart';
import 'package:eefood/features/recipe/domain/repositories/recipe_repository.dart';

class Province {
  final RecipeRepository repository;
  Province(this.repository);

  Future<List<ProvinceModel>> call({String? keyword, int limit=1, int page=5}) => repository.getProvinces(keyword: keyword, limit: limit,page: page);
}

class Ward {
  final RecipeRepository repository;
  Ward(this.repository);

  Future<List<WardModel>> call(String provinceCode, {String? keyword, int limit = 5, int page = 1}) 
    => repository.getWard(provinceCode, keyword: keyword, limit: limit, page: page);
}

class Ingredients {
  final RecipeRepository repository;
  Ingredients(this.repository);

  Future<List<IngredientModel>> call(String? name, int page, int limit) => repository.getAllIngredient(name!,page,limit);
}

class Categories{
  final RecipeRepository repository;
  Categories(this.repository);

  Future<List<CategoryModel>> call(String? name, int page, int limit) => repository.getAllCategories(name!,page,limit);
}

class CreateRecipe {
  final RecipeRepository repository;
  CreateRecipe(this.repository);

  Future<Result<RecipeModel>> call(RecipeModel recipe) => repository.createRecipe(recipe);
}