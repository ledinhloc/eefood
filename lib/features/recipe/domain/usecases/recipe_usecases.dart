import 'package:eefood/features/recipe/data/models/region_model.dart';
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