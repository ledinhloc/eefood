import '../../data/models/shopping_item_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/shopping_ingredient_model.dart';
part 'shopping_state.freezed.dart';

enum ShoppingViewMode { byRecipe, byIngredient }
@freezed
class ShoppingState with _$ShoppingState {
  const factory ShoppingState({
    @Default(false) bool isLoading,
    String? error,
    @Default(<ShoppingItemModel>[]) List<ShoppingItemModel> recipes,
    @Default(<ShoppingIngredientModel>[]) List<ShoppingIngredientModel> ingredients,
    @Default(ShoppingViewMode.byRecipe) ShoppingViewMode viewMode,
  }) = _ShoppingState;
}