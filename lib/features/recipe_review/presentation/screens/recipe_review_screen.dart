import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/recipe_review/domain/repositories/review_recipe_repository.dart';
import 'package:eefood/features/recipe_review/presentation/provider/review_recipe_cubit.dart';
import 'package:eefood/features/recipe_review/presentation/widgets/recipe_review_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecipeReviewScreen extends StatelessWidget {
  final int recipeId;
  const RecipeReviewScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ReviewRecipeCubit(repository: getIt<ReviewRecipeRepository>())
            ..loadQuestions(),
      child: RecipeReviewView(recipeId: recipeId),
    );
  }
}
