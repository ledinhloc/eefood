import 'shopping_ingredient_model.dart';

class ShoppingItemModel {
  final int? id;
  final int? recipeId;
  final String? recipeTitle;
  final int? servings;
  final List<ShoppingIngredientModel> ingredients;

  ShoppingItemModel({
    this.id,
    this.recipeId,
    this.recipeTitle,
    this.servings,
    required this.ingredients,
  });

  factory ShoppingItemModel.fromJson(Map<String, dynamic> json) {
    return ShoppingItemModel(
      id: json['id'] == null ? null : (json['id'] as num).toInt(),
      recipeId: json['recipeId'] == null ? null : (json['recipeId'] as num).toInt(),
      recipeTitle: json['recipeTitle'] as String?,
      servings: json['servings'] == null ? null : (json['servings'] as num).toInt(),
      ingredients: (json['ingredients'] as List<dynamic>? ?? [])
          .map((e) => ShoppingIngredientModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'recipeId': recipeId,
    'recipeTitle': recipeTitle,
    'servings': servings,
    'ingredients': ingredients.map((e) => e.toJson()).toList(),
  };
}
