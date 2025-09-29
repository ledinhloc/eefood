import 'dart:ffi';

import 'package:eefood/features/recipe/data/models/ingredient_model.dart';
import 'package:eefood/features/recipe/domain/entities/ingredient.dart';
import 'package:eefood/features/recipe/domain/entities/recipe_ingredient.dart';

class RecipeIngredientModel {
  final int? id;
  final double? quantity;
  final String? unit;

  final IngredientModel? ingredient;

  RecipeIngredientModel({this.id, this.quantity, this.unit, this.ingredient});

  factory RecipeIngredientModel.fromJson(Map<String, dynamic> json) {
    return RecipeIngredientModel(
      id: json['id'],
      quantity: json['quantity'] != null
          ? (json['quantity'] as num).toDouble()
          : null,
      unit: json['unit'],
      ingredient: json['ingredient'] != null
          ? IngredientModel.fromJson(json['ingredient'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'unit': unit,
      'ingredientId': ingredient?.id,
    };
  }

  RecipeIngredient toEntity() => RecipeIngredient(
    id: id!,
    quantity: quantity,
    unit: unit,
    ingredient: ingredient!.toEntity(),
  );

  RecipeIngredientModel copyWith({
    int? id,
    double? quantity,
    String? unit,
    IngredientModel? ingredient,
  }) {
    return RecipeIngredientModel(
      id: id ?? this.id,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      ingredient: ingredient ?? this.ingredient,
    );
  }
}
