import 'package:eefood/features/recipe/data/models/recipe_compare_model.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_compare_cubit.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_compare_state.dart';
import 'package:eefood/features/recipe/presentation/widgets/compare_recipe/nutrition_compare/nutrition_analyze_prompt.dart';
import 'package:eefood/features/recipe/presentation/widgets/compare_recipe/nutrition_compare/nutrition_compare_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NutritionSectionWrapper extends StatelessWidget {
  final RecipeCompareModel recipeA;
  final RecipeCompareModel recipeB;

  const NutritionSectionWrapper({
    super.key,
    required this.recipeA,
    required this.recipeB,
  });

  bool _hasNutrition(RecipeCompareModel r) =>
      (r.calories ?? 0) > 0 ||
      (r.protein ?? 0) > 0 ||
      (r.fat ?? 0) > 0 ||
      (r.carb ?? 0) > 0 ||
      (r.fiber ?? 0) > 0 ||
      (r.sugar ?? 0) > 0 ||
      (r.sodium ?? 0) > 0;

  @override
  Widget build(BuildContext context) {
    final hasA = _hasNutrition(recipeA);
    final hasB = _hasNutrition(recipeB);

    return BlocBuilder<RecipeCompareCubit, RecipeCompareState>(
      builder: (context, state) {
        if (state is! RecipeCompareLoaded) return const SizedBox.shrink();
        final analyzePrompt = NutritionAnalyzePrompt(
          recipeA: recipeA,
          recipeB: recipeB,
          hasNutritionA: hasA,
          hasNutritionB: hasB,
          isAnalyzingA: state.isAnalyzingA,
          isAnalyzingB: state.isAnalyzingB,
          errorA: state.analyzeErrorA,
          errorB: state.analyzeErrorB,
          onAnalyzeA: () => context.read<RecipeCompareCubit>().analyzeNutrition(
            isRecipeA: true,
          ),
          onAnalyzeB: () => context.read<RecipeCompareCubit>().analyzeNutrition(
            isRecipeA: false,
          ),
        );

        if (hasA && hasB) {
          return NutritionCompareSection(recipeA: recipeA, recipeB: recipeB);
        }

        if (!hasA && !hasB) return analyzePrompt;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NutritionCompareSection(recipeA: recipeA, recipeB: recipeB),
            const SizedBox(height: 12),
            analyzePrompt,
          ],
        );
      },
    );
  }
}
