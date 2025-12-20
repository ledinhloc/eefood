import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';
import 'package:json_annotation/json_annotation.dart';

import 'ingredient_create_request.dart';

part 'recipe_update_request.g.dart';

@JsonSerializable()
class RecipeUpdateRequest {
  final String title;
  final String? description;
  final String? region;
  final String? imageUrl;
  final String? videoUrl;
  final int? prepTime;
  final int? cookTime;
  final String? difficulty;

  final List<String> categories;
  final List<IngredientCreateRequest> ingredients;
  final List<RecipeStepModel> steps;

  RecipeUpdateRequest({
    required this.title,
    this.description,
    this.region,
    this.imageUrl,
    this.videoUrl,
    this.prepTime,
    this.cookTime,
    this.difficulty,
    required this.categories,
    required this.ingredients,
    required this.steps,
  });

  factory RecipeUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$RecipeUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeUpdateRequestToJson(this);
}
