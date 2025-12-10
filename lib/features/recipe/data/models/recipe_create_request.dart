import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';
import 'package:json_annotation/json_annotation.dart';

import 'ingredient_create_request.dart';

part 'recipe_create_request.g.dart';

@JsonSerializable()
class RecipeCreateRequest {
  final String title;
  final String? description;
  final String? imageUrl;
  final String? videoUrl;
  final String? region;
  final int cookTime;
  final int prepTime;
  final String? difficulty;

  final List<String> categories;
  final List<IngredientCreateRequest> ingredients;
  final List<RecipeStepModel> steps;

  RecipeCreateRequest({
    required this.title,
    required this.cookTime,
    required this.prepTime,
    required this.categories,
    required this.ingredients,
    required this.steps,
    this.description,
    this.imageUrl,
    this.videoUrl,
    this.region,
    this.difficulty,
  });

  factory RecipeCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$RecipeCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeCreateRequestToJson(this);
}
