import 'package:eefood/features/recipe/data/models/recipe_compare_response.dart';

abstract class RecipeCompareState {
  const RecipeCompareState();
}

class RecipeCompareInitial extends RecipeCompareState {}

class RecipeCompareLoading extends RecipeCompareState {}

class RecipeCompareLoaded extends RecipeCompareState {
  final RecipeCompareResponse data;
  final bool isAnalyzingA;
  final bool isAnalyzingB;
  final String? analyzeErrorA;
  final String? analyzeErrorB;
  const RecipeCompareLoaded({
    required this.data,
    this.isAnalyzingA = false,
    this.isAnalyzingB = false,
    this.analyzeErrorA,
    this.analyzeErrorB,
  });

  RecipeCompareLoaded copyWith({
    RecipeCompareResponse? data,
    bool? isAnalyzingA,
    bool? isAnalyzingB,
    String? analyzeErrorA,
    String? analyzeErrorB,
    bool clearErrorA = false,
    bool clearErrorB = false,
  }) {
    return RecipeCompareLoaded(
      data: data ?? this.data,
      isAnalyzingA: isAnalyzingA ?? this.isAnalyzingA,
      isAnalyzingB: isAnalyzingB ?? this.isAnalyzingB,
      analyzeErrorA: clearErrorA ? null : (analyzeErrorA ?? this.analyzeErrorA),
      analyzeErrorB: clearErrorB ? null : (analyzeErrorB ?? this.analyzeErrorB),
    );
  }

  bool get needsAnalysisA => _noNutrition(data.recipeA?.calories);
  bool get needsAnalysisB => _noNutrition(data.recipeB?.calories);
  bool get anyNeedsAnalysis => needsAnalysisA || needsAnalysisB;

  static bool _noNutrition(double? v) => v == null || v == 0;
}

class RecipeCompareError extends RecipeCompareState {
  final String message;

  const RecipeCompareError({required this.message});
}
