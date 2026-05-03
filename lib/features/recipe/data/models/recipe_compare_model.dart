import 'package:json_annotation/json_annotation.dart';

part 'recipe_compare_model.g.dart';

@JsonSerializable()
class RecipeCompareModel {
  final int? id;
  final String? title;
  final String? imageUrl;
  final String? videoUrl;
  final int? prepTime;
  final int? cookTime;
  final int? totalTime;
  final String? difficulty;
  final String? region;
  final int? stepCount;
  final int? ingredientCount;

  final double? calories;
  final double? protein;
  final double? fat;
  final double? carb;
  final double? fiber;
  final double? sugar;
  final double? cal;
  final double? sodium;
  final double? healthScore;

  RecipeCompareModel({
    this.id,
    this.title,
    this.imageUrl,
    this.videoUrl,
    this.prepTime,
    this.cookTime,
    this.totalTime,
    this.difficulty,
    this.region,
    this.stepCount,
    this.ingredientCount,
    this.calories,
    this.protein,
    this.fat,
    this.carb,
    this.fiber,
    this.sugar,
    this.cal,
    this.sodium,
    this.healthScore,
  });

  factory RecipeCompareModel.fromJson(Map<String, dynamic> json) =>
      _$RecipeCompareModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeCompareModelToJson(this);
}
