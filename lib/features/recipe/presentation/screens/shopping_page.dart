import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_bottom_sheet.dart';
import '../../../../core/widgets/snack_bar.dart';
import '../../data/models/shopping_item_model.dart';
import '../provider/shopping_cubit.dart';
import '../provider/shopping_state.dart';
import '../widgets/ingredient_tile.dart';
import '../widgets/recipe_card.dart';

class ShoppingPage extends StatelessWidget {
  const ShoppingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ShoppingCubit()..load(),
      child: const ShoppingView(),
    );
  }
}

class ShoppingView extends StatelessWidget {
  const ShoppingView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shopping List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          BlocBuilder<ShoppingCubit, ShoppingState>(
            builder: (context, state){
              return TextButton.icon(
                icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                label: Text(
                  state.viewMode == ShoppingViewMode.byRecipe ? 'công thức' : 'nguyên liệu',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ),
                onPressed: () {
                  showCustomBottomSheet(context, [
                    BottomSheetOption(
                      icon: Icons.list,
                      title: "Xem theo công thức",
                      onTap: () {
                        context.read<ShoppingCubit>().loadByRecipe();
                      },
                    ),
                    BottomSheetOption(
                      icon: Icons.shopping_cart,
                      title: "Xem theo nguyên liệu",
                      onTap: () {
                        context.read<ShoppingCubit>().loadByIngredient();
                      },
                    ),
                  ]);
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<ShoppingCubit, ShoppingState>(
          builder: (context, state) {
            // if (state.isLoading) {
            //   return const Center(child: CircularProgressIndicator());
            // }
            if (state.error != null) {
              return Center(child: Text('Error: ${state.error}'));
            }
            final isByRecipe = state.viewMode == ShoppingViewMode.byRecipe;
            return isByRecipe
                ? _buildRecipeList(state.recipes, context)
                : _buildIngredientList(state.ingredients, context);
          },
        ),
      ),
    );
  }

  Widget _buildRecipeList(
    List<ShoppingItemModel> recipes,
    BuildContext context,
  ) {
    if (recipes.isEmpty) {
      return const Center(
        child: Text('Không có công thức nào trong shopping list'),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<ShoppingCubit>().load(),
      child: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final item = recipes[index];
          return Dismissible(
            key: ValueKey(item.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) {
              context.read<ShoppingCubit>().removeItem(item.id ?? 0);
            },
            child: RecipeCard(item: item),
          );
        },
      ),
    );
  }

  Widget _buildIngredientList(List ingredients, BuildContext context) {
    if (ingredients.isEmpty) {
      return const Center(child: Text('Không có nguyên liệu'));
    }
    return RefreshIndicator(
      onRefresh: () => context.read<ShoppingCubit>().load(),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: ingredients.length,
          itemBuilder: (context, index) {
            final ing = ingredients[index];
            return Dismissible(
              key: ValueKey(ing.ingredientId ?? index),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) {
                // context.read<ShoppingCubit>().removeIngredient(ing.ingredientId ?? 0);
                showCustomSnackBar(context, 'Deleted success ', isError: false);
              },
              child: IngredientTile(
                ingredient: ing,
                onToggle: (val) => context.read<ShoppingCubit>().togglePurchased(
                  ing.ingredientId ?? 0,
                  val ?? false,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
