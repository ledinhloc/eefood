import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/shopping_item_model.dart';
import '../../data/models/shopping_ingredient_model.dart';
import '../../domain/repositories/shopping_repository.dart';
import 'shopping_state.dart';

class ShoppingCubit extends Cubit<ShoppingState> {
  final ShoppingRepository repository = getIt<ShoppingRepository>();

  ShoppingCubit() : super(const ShoppingState());

  Future<void> loadByRecipe() async {
    emit(state.copyWith(isLoading: true, error: null));
    try{
      final recipes = await repository.getByRecipe();
      emit(state.copyWith(isLoading: false, recipes: recipes, viewMode: ShoppingViewMode.byRecipe));
    }catch (e){
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadByIngredient() async {
    emit(state.copyWith(isLoading: true, error: null));
    try{
      final ingredients = await repository.getByIngredient();
      emit(state.copyWith(isLoading: false, ingredients: ingredients, viewMode: ShoppingViewMode.byIngredient));
    }catch (e){
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final recipes = await repository.getByRecipe();
      final ingredients = await repository.getByIngredient();
      emit(state.copyWith(isLoading: false, recipes: recipes, ingredients: ingredients));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void toggleView() {
    final next = state.viewMode == ShoppingViewMode.byRecipe ? ShoppingViewMode.byIngredient : ShoppingViewMode.byRecipe;
    emit(state.copyWith(viewMode: next));
  }

  Future<void> togglePurchased(int ingredientId, bool purchased) async {
    try {
      await repository.togglePurchased(ingredientId, purchased);
      final updated = state.ingredients.map((ing) {
        if (ing.ingredientId == ingredientId || ing.id == ingredientId) {
          return ing.copyWith(purchased: purchased);
        }
        return ing;
      }).toList();
      emit(state.copyWith(ingredients: updated));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateServings(int itemId, int servings) async {
    try {
      await repository.updateServings(itemId, servings);
      // reload for simplicity
      await load();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> removeItem(int itemId) async {
    try {
      await repository.removeItem(itemId);
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
