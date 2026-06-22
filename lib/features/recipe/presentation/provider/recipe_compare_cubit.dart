import 'package:eefood/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:eefood/features/recipe/data/models/recipe_compare_response.dart';
import 'package:eefood/features/recipe/domain/repositories/recipe_repository.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_compare_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecipeCompareCubit extends Cubit<RecipeCompareState> {
  final RecipeRepository repository;
  final NutritionRepository nutritionRepository;

  RecipeCompareCubit({
    required this.repository,
    required this.nutritionRepository,
  }) : super(RecipeCompareInitial());

  Future<void> analyzeNutrition({required bool isRecipeA}) async {
    final current = state;
    if (current is! RecipeCompareLoaded) return;

    final recipe = isRecipeA ? current.data.recipeA : current.data.recipeB;
    if (recipe?.id == null) return;

    emit(
      current.copyWith(
        isAnalyzingA: isRecipeA ? true : null,
        isAnalyzingB: isRecipeA ? null : true,
        clearErrorA: isRecipeA,
        clearErrorB: !isRecipeA,
      ),
    );

    try {
      final nutrition = await nutritionRepository.getNutritionByRecipeId(
        recipe!.id!,
      );
      if (nutrition == null)
        throw Exception('Không lấy được dữ liệu dinh dưỡng');

      final patched = recipe.patchFromNutrition(nutrition);

      final latest = state;
      if (latest is! RecipeCompareLoaded) return;

      final newData = isRecipeA
          ? RecipeCompareResponse(
              recipeA: patched,
              recipeB: latest.data.recipeB,
            )
          : RecipeCompareResponse(
              recipeA: latest.data.recipeA,
              recipeB: patched,
            );
      emit(
        latest.copyWith(
          data: newData,
          isAnalyzingA: isRecipeA ? false : null,
          isAnalyzingB: isRecipeA ? null : false,
        ),
      );
    } catch (e) {
      final latest = state;
      if (latest is! RecipeCompareLoaded) return;
      emit(
        latest.copyWith(
          isAnalyzingA: isRecipeA ? false : null,
          isAnalyzingB: isRecipeA ? null : false,
          analyzeErrorA: isRecipeA ? e.toString() : null,
          analyzeErrorB: isRecipeA ? null : e.toString(),
        ),
      );
    }
  }

  Future<void> compareRecipes(int recipeIdA, int recipeIdB) async {
    emit(RecipeCompareLoading());
    try {
      final result = await repository.compareRecipe(recipeIdA, recipeIdB);
      if (result != null) {
        emit(RecipeCompareLoaded(data: result));
      } else {
        emit(
          const RecipeCompareError(message: 'Không tìm thấy kết quả so sánh'),
        );
      }
    } catch (e) {
      emit(RecipeCompareError(message: e.toString()));
    }
  }

  void reset() => emit(RecipeCompareInitial());
}
