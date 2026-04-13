import 'package:eefood/features/cook_process/data/models/ingredient_alter_response.dart';

abstract class IngredientAlterRepository {
  Future<IngredientAlterModel?> getIngredientAlter(
    int recipeId,
    int ingredientId,
  );
  Future<void> selectAlterIngredient(
    int recipeId,
    int ingredientId,
    int substituteId,
  );
}
