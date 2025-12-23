import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/recipe/data/models/recipe_Ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';
import 'package:eefood/features/recipe/domain/usecases/recipe_usecases.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/ingredient_create_request.dart';
import '../../data/models/recipe_create_request.dart';
import '../../data/models/recipe_update_request.dart';

class RecipeCrudCubit extends Cubit<RecipeCrudState> {
  final CreateRecipe _createRecipe = getIt<CreateRecipe>();
  final CreateRecipeFromUrl _createRecipeFromUrl = getIt<CreateRecipeFromUrl>();
  final UpdateRecipe _updateRecipe = getIt<UpdateRecipe>();
  final DeleteRecipe _deleteRecipe = getIt<DeleteRecipe>();
  RecipeCrudCubit(RecipeModel? initialRecipe)
    : super(RecipeCrudState.initial(initialRecipe));

  Future<void> init(RecipeModel? initial) async {
    if (initial != null) {
      // Nếu có categoryIds, convert sang List<String> categories
      List<String> categoryNames = [];
      if (initial.categories != null && initial.categories!.isNotEmpty) {
        categoryNames = initial.categories!
            .map((cat) => cat.description ?? '')
            .where((des) => des.isNotEmpty)
            .toList();
        print(
          'Init: Extracted ${categoryNames.length} categories: $categoryNames',
        );
      }

      emit(
        state.copyWith(
          recipe: initial,
          // categoryIds: initial.categoryIds ?? [],
          categories: categoryNames,
          ingredients: initial.ingredients ?? [],
          steps: initial.steps ?? [],
        ),
      );
    }
  }

  void setCategories(List<String> categories) {
    emit(state.copyWith(categories: List<String>.from(categories)));
  }

  void addCategory(String value) {
    final newList = List<String>.from(state.categories);
    if (!newList.contains(value)) {
      newList.add(value);
      emit(state.copyWith(categories: newList));
    }
  }

  void removeCategory(String value) {
    final newList = List<String>.from(state.categories)..remove(value);
    emit(state.copyWith(categories: newList));
  }

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
    final updatedRecipe = state.recipe.copyWith(ingredients: newIngredients);
    emit(state.copyWith(ingredients: newIngredients, recipe: updatedRecipe));
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
    final updatedRecipe = state.recipe.copyWith(steps: newSteps);
    emit(state.copyWith(steps: newSteps, recipe: updatedRecipe));
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

  List<IngredientCreateRequest> _mapIngredients() {
    return state.ingredients
        .map(
          (e) => IngredientCreateRequest(
            name: e.ingredient!.name,
            quantity: e.quantity,
            unit: e.unit,
          ),
        )
        .toList();
  }

  void saveRecipe() async {
    emit(state.copyWith(isLoading: true));

    final request = RecipeCreateRequest(
      title: state.recipe.title,
      description: state.recipe.description,
      imageUrl: state.recipe.imageUrl,
      videoUrl: state.recipe.videoUrl,
      region: state.recipe.region,
      cookTime: state.recipe.cookTime ?? 0,
      prepTime: state.recipe.prepTime ?? 0,
      difficulty: state.recipe.difficulty?.name,

      categories: state.categories,
      ingredients: _mapIngredients(),
      steps: state.steps,
    );

    print(request.toJson());

    final result = await _createRecipe(request);
    //final result = await _createRecipe(savedRecipe);

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

  void updateExistingRecipe(int id) async {
    emit(state.copyWith(isLoading: true));

    // Tạo recipe mới từ state hiện tại
    final updatedRecipe = RecipeUpdateRequest(
      title: state.recipe.title,
      description: state.recipe.description,
      region: state.recipe.region,
      imageUrl: state.recipe.imageUrl,
      videoUrl: state.recipe.videoUrl,
      prepTime: state.recipe.prepTime,
      cookTime: state.recipe.cookTime,
      difficulty: state.recipe.difficulty?.name,
      categories: state.categories,
      ingredients: _mapIngredients(),
      steps: state.steps,
    );

    print('=== UPDATING RECIPE ===');
    print('Local ingredients count: ${state.ingredients.length}');
    print('Recipe to update: ${updatedRecipe.toJson()}');

    final result = await _updateRecipe(id, updatedRecipe);

    if (result.isSuccess && result.data != null) {
      final serverRecipe = result.data!;

      emit(
        state.copyWith(
          recipe: serverRecipe,
          isLoading: false,
          message: "Recipe updated successfully",
        ),
      );
    } else {
      emit(
        state.copyWith(
          isLoading: false,
          message:
              "Failed to update recipe: ${result.error ?? "Unknown error"}",
        ),
      );
    }
  }

  Future<void> deleteRecipe(int id) async {
    emit(state.copyWith(isLoading: true));

    final result = await _deleteRecipe(id);

    if (result.isSuccess) {
      emit(
        RecipeCrudState.initial(
          null,
        ).copyWith(isLoading: false, message: result.data),
      );
    } else {
      emit(
        state.copyWith(
          isLoading: false,
          message:
              "Failed to delete recipe: ${result.error ?? "Unknown error"}",
        ),
      );
    }
  }
}
