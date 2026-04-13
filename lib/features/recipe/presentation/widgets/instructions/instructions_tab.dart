import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/cook_process/presentation/provider/ingredient_alter_cubit.dart';
import 'package:eefood/features/cook_process/presentation/widgets/ingredient_substitute_sheet.dart';
import 'package:eefood/features/recipe/data/models/recipe_Ingredient_model.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_detail_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InstructionsTab extends StatelessWidget {
  const InstructionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<RecipeDetailCubit, RecipeDetailState>(
      builder: (ctx, state) {
        final recipe = state.recipe;
        if (recipe == null) return const SizedBox();
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: recipe.ingredients?.length ?? 0,
          itemBuilder: (context, index) {
            final ing = recipe.ingredients![index];
            final imageUrl = ing.ingredient?.image;

            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: (imageUrl != null && imageUrl.isNotEmpty)
                    ? Image.network(
                        imageUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 40,
                          );
                        },
                      )
                    : const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 40,
                      ),
              ),
              title: Text(ing.ingredient?.name ?? ''),
              subtitle: Text("${ing.quantity ?? ''} ${ing.unit ?? ''}"),
              trailing: IconButton(
                onPressed: () => _showIngredientSubstituteBottomSheet(
                  ctx,
                  ing,
                  recipe.id!,
                ),
                icon: Icon(
                  Icons.change_circle_outlined,
                  color: theme.colorScheme.onSurface,
                  size: 25,
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showIngredientSubstituteBottomSheet(
    BuildContext ctx,
    RecipeIngredientModel ingre,
    int recipeId,
  ) async {
    final ingredientId = ingre.ingredient?.originalId ?? ingre.ingredient?.id;
    if (ingredientId == null) return;

    final cubit = getIt<IngredientAlterCubit>();
    final recipeDetailCubit = ctx.read<RecipeDetailCubit>();

    cubit.load(recipeId, ingredientId);

    final result = await showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (_) {
        return BlocProvider.value(
          value: cubit,
          child: IngredientSubstituteSheet(ingre: ingre, recipeId: recipeId),
        );
      },
    );

    await cubit.close();

    // Nếu user đã xác nhận chọn nguyên liệu thay thế → reload
    if (result != null) {
      recipeDetailCubit.loadRecipe(recipeId);
    }
  }
}
