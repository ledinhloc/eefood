import 'package:eefood/features/recipe/domain/repositories/recipe_repository.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_compare_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecipeCompareCubit extends Cubit<RecipeCompareState> {
  final RecipeRepository repository;

  RecipeCompareCubit({required this.repository}): super(RecipeCompareInitial());

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
