import 'package:eefood/features/cook_process/data/models/ingredient_alter_response.dart';

class IngredientAlterState {
  final bool isLoading;
  final bool isSelecting;
  final IngredientAlterModel? data;
  final String? error;
  final int? originalIngredientId;

  IngredientAlterState({
    this.isLoading = false,
    this.isSelecting = false,
    this.data,
    this.error,
    this.originalIngredientId,
  });

  IngredientAlterState copyWith({
    bool? isLoading,
    bool? isSelecting,
    IngredientAlterModel? data,
    String? error,
    int? originalIngredientId,
  }) {
    return IngredientAlterState(
      isLoading: isLoading ?? this.isLoading,
      isSelecting: isSelecting ?? this.isSelecting,
      data: data ?? this.data,
      error: error,
      originalIngredientId: originalIngredientId ?? this.originalIngredientId,
    );
  }
}