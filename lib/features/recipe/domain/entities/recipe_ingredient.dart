import 'package:eefood/features/recipe/domain/entities/ingredient.dart';

class RecipeIngredient {
  final int id;
  final double? quantity;
  final String? unit;

  final Ingredient? ingredient;

  RecipeIngredient({
    required this.id,
    this.quantity,
    this.unit,
    this.ingredient
  });
}