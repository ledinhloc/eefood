import 'package:eefood/features/recipe/data/models/recipe_compare_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recipe_compare_response.g.dart';

@JsonSerializable()
class RecipeCompareResponse {
  RecipeCompareModel? recipeA;
  RecipeCompareModel? recipeB;

  RecipeCompareResponse({this.recipeA, this.recipeB});

  factory RecipeCompareResponse.fromJson(Map<String, dynamic> json) =>
      _$RecipeCompareResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeCompareResponseToJson(this);
}
