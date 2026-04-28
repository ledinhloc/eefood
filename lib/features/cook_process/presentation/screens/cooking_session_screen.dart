import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/cook_process/presentation/provider/cooking_session_cubit.dart';
import 'package:eefood/features/cook_process/presentation/widgets/cooking_session_view.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CookingSessionScreen extends StatelessWidget {
  final int recipeId;
  final String recipeTitle;
  final List<RecipeStepModel> steps;
  const CookingSessionScreen({
    super.key,
    required this.recipeId,
    required this.recipeTitle,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CookingSessionCubit>()..initSession(recipeId, steps),
      child: CookingSessionView(recipeTitle: recipeTitle, recipeId: recipeId),
    );
  }
}
