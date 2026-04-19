import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../data/models/post_publish_model.dart';
import '../../domain/repositories/post_publish_repository.dart';

class SimilarRecipesState {
  final bool isLoading;
  final List<PostPublishModel> recipes;
  final String? error;

  const SimilarRecipesState({
    this.isLoading = false,
    this.recipes = const [],
    this.error,
  });

  SimilarRecipesState copyWith({
    bool? isLoading,
    List<PostPublishModel>? recipes,
    String? error,
  }) {
    return SimilarRecipesState(
      isLoading: isLoading ?? this.isLoading,
      recipes: recipes ?? this.recipes,
      error: error,
    );
  }
}

class SimilarRecipesCubit extends Cubit<SimilarRecipesState> {
  final PostPublishRepository _repository = getIt<PostPublishRepository>();

  SimilarRecipesCubit() : super(const SimilarRecipesState());

  Future<void> loadSimilarRecipes(int recipeId, {int limit = 10}) async {
    emit(const SimilarRecipesState(isLoading: true));

    try {
      final recipes = await _repository.getSimilarRecipes(
        recipeId,
        limit: limit,
      );
      emit(SimilarRecipesState(recipes: recipes));
    } catch (e) {
      emit(SimilarRecipesState(error: e.toString()));
    }
  }
}
