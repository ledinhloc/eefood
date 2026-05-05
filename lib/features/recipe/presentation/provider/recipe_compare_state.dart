import 'package:eefood/features/recipe/data/models/recipe_compare_response.dart';

abstract class RecipeCompareState {
  const RecipeCompareState();
}

class RecipeCompareInitial extends RecipeCompareState {}

class RecipeCompareLoading extends RecipeCompareState {}

class RecipeCompareLoaded extends RecipeCompareState {
  final RecipeCompareResponse data;

  const RecipeCompareLoaded({required this.data});
}

class RecipeCompareError extends RecipeCompareState {
  final String message;

  const RecipeCompareError({required this.message});
}
