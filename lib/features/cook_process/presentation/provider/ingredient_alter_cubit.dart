import 'package:eefood/features/cook_process/domain/repositories/ingredient_alter_repository.dart';
import 'package:eefood/features/cook_process/presentation/provider/ingredient_alter_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IngredientAlterCubit extends Cubit<IngredientAlterState> {
  final IngredientAlterRepository repository;
  IngredientAlterCubit({required this.repository})
    : super(IngredientAlterState());

  void _safeEmit(IngredientAlterState state) {
    if (!isClosed) {
      emit(state);
    }
  }

  Future<void> load(int recipeId, int ingredientId) async {
    _safeEmit(state.copyWith(isLoading: true, error: null));
    try {
      final data = await repository.getIngredientAlter(recipeId, ingredientId);

      _safeEmit(
        state.copyWith(
          isLoading: false,
          data: data,
          originalIngredientId:
              data?.ingredient?.originalId ?? data?.ingredient?.id,
        ),
      );
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> select(int recipeId, int ingredientId, int substituteId) async {
    _safeEmit(state.copyWith(isSelecting: true));

    try {
      await repository.selectAlterIngredient(
        recipeId,
        ingredientId,
        substituteId,
      );

      final data = await repository.getIngredientAlter(recipeId, ingredientId);

      _safeEmit(state.copyWith(isSelecting: false, data: data));
    } catch (e) {
      _safeEmit(state.copyWith(isSelecting: false, error: e.toString()));
    }
  }
}
