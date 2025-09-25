import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/recipe/data/models/category_model.dart';
import 'package:eefood/features/recipe/data/models/ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_Ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';
import 'package:eefood/features/recipe/domain/usecases/recipe_usecases.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecipeCrudCubit extends Cubit<RecipeCrudState> {
  final CreateRecipe _createRecipe = getIt<CreateRecipe>();
  RecipeCrudCubit(RecipeModel? initialRecipe)
    : super(RecipeCrudState.initial(initialRecipe));

  void updateRecipe(RecipeModel updatedRecipe) {
    emit(state.copyWith(recipe: updatedRecipe));
  }

  void addIngredient(RecipeIngredientModel ingredient) {
    final newIngredients = List<RecipeIngredientModel>.from(state.ingredients)
      ..add(ingredient);
    emit(state.copyWith(ingredients: newIngredients));
  }

  void updateIngredients(int index, RecipeIngredientModel updated) {
    final newIngredients = List<RecipeIngredientModel>.from(state.ingredients);
    newIngredients[index] = updated;
    emit(state.copyWith(ingredients: newIngredients));
  }

  void removeIngredient(int index) {
    final newIngredients = List<RecipeIngredientModel>.from(state.ingredients)
      ..removeAt(index);
    emit(state.copyWith(ingredients: newIngredients));
  }

  void reorderIngredients(int oldIndex, int newIndex) {
    final newIngredients = List<RecipeIngredientModel>.from(state.ingredients);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = newIngredients.removeAt(oldIndex);
    newIngredients.insert(newIndex, item);
    emit(state.copyWith(ingredients: newIngredients));
  }

  void addStep(RecipeStepModel step) {
    final newSteps = List<RecipeStepModel>.from(state.steps)
      ..add(step.copyWith(stepNumber: state.steps.length + 1));
    emit(state.copyWith(steps: newSteps));
  }

  void updateStep(int index, RecipeStepModel updated) {
    final newSteps = List<RecipeStepModel>.from(state.steps);
    newSteps[index] = updated.copyWith(stepNumber: index + 1);
    emit(state.copyWith(steps: newSteps));
  }

  void removeStep(int index) {
    final newSteps = List<RecipeStepModel>.from(state.steps)..removeAt(index);
    for (int i = 0; i < newSteps.length; i++) {
      newSteps[i] = newSteps[i].copyWith(stepNumber: i + 1);
    }
    emit(state.copyWith(steps: newSteps));
  }

  void reorderSteps(int oldIndex, int newIndex) {
    final newSteps = List<RecipeStepModel>.from(state.steps);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = newSteps.removeAt(oldIndex);
    newSteps.insert(newIndex, item);
    for (int i = 0; i < newSteps.length; i++) {
      newSteps[i] = newSteps[i].copyWith(stepNumber: i + 1);
    }
    emit(state.copyWith(steps: newSteps));
  }

  void setCategories(List<int> categoryIds) {
    emit(state.copyWith(categoryIds: List<int>.from(categoryIds)));
  }

  void updateCategory(int index, int updatedId) {
    final newCategories = List<int>.from(state.categoryIds);
    newCategories[index] = updatedId;
    emit(state.copyWith(categoryIds: newCategories));
  }

  void removeCategory(int categoryId) {
    final newCategories = List<int>.from(state.categoryIds)..remove(categoryId);
    emit(state.copyWith(categoryIds: newCategories));
  }

  void saveRecipe() async {
    final savedRecipe = state.recipe.copyWith(
      ingredients: state.ingredients,
      steps: state.steps,
      categoryIds: state.categoryIds,
    );
    final result = await _createRecipe(savedRecipe);

    if (result.isSuccess && result.data != null) {
      emit(
        state.copyWith(
          recipe: result.data!, 
          isLoading: false,
          message: "Recipe created successfully",
        ),
      );
    } else {
      emit(
        state.copyWith(
          isLoading: false,
          message:
              "Failed to create recipe: ${result.error ?? "Unknown error"}",
        ),
      );
    }
  }

  void deleteRecipe() {
    emit(RecipeCrudState.initial(null));
  }
}


