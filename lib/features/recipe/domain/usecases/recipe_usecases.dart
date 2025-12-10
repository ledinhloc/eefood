import 'package:eefood/features/auth/data/models/result_model.dart';
import 'package:eefood/features/recipe/data/models/category_model.dart';
import 'package:eefood/features/recipe/data/models/ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_create_request.dart';
import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:eefood/features/recipe/data/models/region_model.dart';
import 'package:eefood/features/recipe/domain/entities/recipe.dart';
import 'package:eefood/features/recipe/domain/repositories/recipe_repository.dart';

class Province {
  final RecipeRepository repository;
  Province(this.repository);

  Future<List<ProvinceModel>> call({
    String? keyword,
    int limit = 1,
    int page = 5,
  }) => repository.getProvinces(keyword: keyword, limit: limit, page: page);
}

class Ingredients {
  final RecipeRepository repository;
  Ingredients(this.repository);

  Future<List<IngredientModel>> call(String? name, int page, int limit) =>
      repository.getAllIngredient(name!, page, limit);
}

class Categories {
  final RecipeRepository repository;
  Categories(this.repository);

  Future<List<CategoryModel>> call(String? name, int page, int limit) =>
      repository.getAllCategories(name!, page, limit);
}

class CreateRecipe {
  final RecipeRepository repository;
  CreateRecipe(this.repository);

  Future<Result<RecipeModel>> call(RecipeCreateRequest recipe) => repository.createRecipe(recipe);
}

class CreateRecipeFromUrl {
  final RecipeRepository repository;
  CreateRecipeFromUrl(this.repository);

  Future<Result<RecipeModel>> call(String url) => repository.createRecipeFromUrl(url);
}

class UpdateRecipe {
  final RecipeRepository repository;
  UpdateRecipe(this.repository);

  Future<Result<RecipeModel>> call(int id, RecipeModel recipe) => repository.updateRecipe(id,recipe);
}

class DeleteRecipe {
  final RecipeRepository repository;
  DeleteRecipe(this.repository);

  Future<Result<String>> call(int id) => repository.deleteRecipe(id);
}

class GetMyRecipe {
  final RecipeRepository repository;
  GetMyRecipe(this.repository);

  Future<Result<List<RecipeModel>>> call(
    String? title,
    String? description,
    String? region,
    String? difficulty,
    int? categoryId,
    int page,
    int size,
    String sortBy,
    String direction,
  ) => repository.getMyRecipe(
    title,
    description,
    region,
    difficulty,
    categoryId,
    page = 1,
    size = 5,
    sortBy = 'createdAt',
    direction = 'DESC',
  );
}
