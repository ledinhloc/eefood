import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/shopping_ingredient_model.dart';
import '../../domain/repositories/shopping_repository.dart';
import 'shopping_state.dart';

class ShoppingCubit extends Cubit<ShoppingState> {
  final ShoppingRepository repository = getIt<ShoppingRepository>();

  ShoppingCubit() : super(const ShoppingState());

  Future<void> loadByRecipe() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final recipes = await repository.getByRecipe();
      emit(
        state.copyWith(
          isLoading: false,
          recipes: recipes,
          viewMode: ShoppingViewMode.byRecipe,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadByIngredient() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final ingredients = await repository.getByIngredient();
      emit(
        state.copyWith(
          isLoading: false,
          ingredients: ingredients,
          viewMode: ShoppingViewMode.byIngredient,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final recipes = await repository.getByRecipe();
      final ingredients = await repository.getByIngredient();
      emit(
        state.copyWith(
          isLoading: false,
          recipes: recipes,
          ingredients: ingredients,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void toggleView() {
    final next = state.viewMode == ShoppingViewMode.byRecipe
        ? ShoppingViewMode.byIngredient
        : ShoppingViewMode.byRecipe;
    emit(state.copyWith(viewMode: next));
  }

  // cập nhật ingredient
  List<ShoppingIngredientModel> _updateIngredients(
      List<ShoppingIngredientModel> ingredients,
      List<int> shoppingIngredientIds,
      bool purchased) {
    return ingredients.map((ing) {
      return shoppingIngredientIds.contains(ing.id)
        ? ing.copyWith(purchased: purchased)
        : ing;
    }).toList();
  }

  Future<void> togglePurchased(ShoppingIngredientModel ing, bool purchased) async {
    final prevState = state;

    final List<int> shoppingIds = ing.shoppingIngredientIds != null && ing.shoppingIngredientIds!.isNotEmpty
        ? ing.shoppingIngredientIds!        // dùng list trong model
        : (ing.id != null ? [ing.id!] : []); // fallback về id đơn lẻ

    if(shoppingIds.isEmpty){
      return;
    }

    // cập nhật recipes
    final updatedRecipes = state.recipes.map((recipe) {
      return recipe.copyWith(
        ingredients: _updateIngredients(recipe.ingredients, shoppingIds, purchased),
      );
    }).toList();

    // cập nhật ingredients
    final updatedIngredients = _updateIngredients(state.ingredients, shoppingIds, purchased);

    emit(state.copyWith(ingredients: updatedIngredients, recipes: updatedRecipes));
    try {
      await repository.togglePurchased(shoppingIds, purchased);
    } catch (e) {
      // rollback lại nếu call API thất bại
      emit(prevState.copyWith(error: e.toString()));
    }
  }

  Future<void> updateServings(int recipeId, int servings) async {
    try {
      await repository.updateServings(recipeId, servings);
      // reload for simplicity
      await load();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> removeItem(int recipeId) async {
    try {
      await repository.removeItem(recipeId);
      await load();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> addRecipe(int recipeId) async {
    try {
      await repository.addRecipe(recipeId);
      await load();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
