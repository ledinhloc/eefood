import '../../data/models/shopping_item_model.dart';
import '../../data/models/shopping_ingredient_model.dart';

enum ShoppingViewMode { byRecipe, byIngredient }

class ShoppingState {
  final bool isLoading;
  final String? error;
  final List<ShoppingItemModel> recipes;
  final List<ShoppingIngredientModel> ingredients;
  final ShoppingViewMode viewMode;

  const ShoppingState({
    this.isLoading = false,
    this.error,
    this.recipes = const [],
    this.ingredients = const [],
    this.viewMode = ShoppingViewMode.byRecipe,
  });

  ShoppingState copyWith({
    bool? isLoading,
    String? error,
    List<ShoppingItemModel>? recipes,
    List<ShoppingIngredientModel>? ingredients,
    ShoppingViewMode? viewMode,
  }) {
    return ShoppingState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      recipes: recipes ?? this.recipes,
      ingredients: ingredients ?? this.ingredients,
      viewMode: viewMode ?? this.viewMode,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, recipes, ingredients, viewMode];
}
