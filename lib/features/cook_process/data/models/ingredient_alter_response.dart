import 'package:eefood/features/recipe/data/models/ingredient_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ingredient_alter_response.g.dart';

@JsonSerializable()
class IngredientAlterModel {
  final IngredientModel? ingredient;
  final IngredientModel? selectedSubstitute;
  final List<IngredientModel>? substitute;

  IngredientAlterModel({
    this.ingredient,
    this.selectedSubstitute,
    this.substitute,
  });

  factory IngredientAlterModel.fromJson(Map<String, dynamic> json) =>
      _$IngredientAlterModelFromJson(json);
  Map<String, dynamic> toJson() => _$IngredientAlterModelToJson(this);

  IngredientAlterModel copyWith({
    IngredientModel? ingredient,
    IngredientModel? selectedSubstitute,
    List<IngredientModel>? substitute,
  }) {
    return IngredientAlterModel(
      ingredient: ingredient ?? this.ingredient,
      selectedSubstitute: selectedSubstitute ?? this.selectedSubstitute,
      substitute: substitute ?? this.substitute,
    );
  }
}
