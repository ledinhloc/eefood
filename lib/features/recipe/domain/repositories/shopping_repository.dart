import '../../data/models/shopping_item_model.dart';
import '../../data/models/shopping_ingredient_model.dart';

abstract class ShoppingRepository {
  Future<List<ShoppingItemModel>> getByRecipe();
  Future<List<ShoppingIngredientModel>> getByIngredient();
  Future<void> addRecipe(int recipeId, {int servings = 1});
  Future<void> removeItem(int itemId);
  Future<void> updateServings(int itemId, int servings);
  Future<void> togglePurchased(List<int> ingredientIds, bool purchased);
}
