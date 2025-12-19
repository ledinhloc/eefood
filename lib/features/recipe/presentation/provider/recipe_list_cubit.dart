import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/recipe/domain/usecases/recipe_usecases.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecipeListCubit extends Cubit<RecipeListState> {
  final GetMyRecipe _getMyRecipe = getIt<GetMyRecipe>();

  RecipeListCubit() : super(RecipeListState());

  void _safeEmit(RecipeListState newState) {
    if (!isClosed) {
      emit(newState);
    }
  }

  Future<void> fetchDraftRecipes({bool loadMore = false}) async {
    if (state.isLoading || (!state.hasDraftMore && loadMore)) return;
    if (isClosed) return;

    _safeEmit(state.copyWith(isLoading: true));

    try {
      final nextPage = loadMore ? state.draftCurrentPage + 1 : 1;
      final result = await _getMyRecipe(
        null, // title
        null, // description
        null, // region
        null, // difficulty
        null, // categoryId
        nextPage,
        10, // size
        'createdAt',
        'DESC',
      );

      if (result.isSuccess && result.data != null) {
        final recipes = result.data!;
        print(
          'Loaded draft recipes - Page: $nextPage, Count: ${recipes.length}',
        );

        _safeEmit(
          state.copyWith(
            draftRecipes: loadMore
                ? [...state.draftRecipes, ...recipes]
                : recipes,
            isLoading: false,
            hasDraftMore: recipes.length == 10,
            draftCurrentPage: nextPage,
          ),
        );
      } else {
        _safeEmit(state.copyWith(isLoading: false, error: result.error));
      }
    } catch (e) {
      print('Error fetching draft recipes: $e');
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> refresh() async  {
    _safeEmit(state.copyWith(
      draftRecipes: [],
      draftCurrentPage: 0,
      hasDraftMore: true,
      isLoading: false,
      error: null,
    ));
    await fetchDraftRecipes();
  }
}
