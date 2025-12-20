import 'package:eefood/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_bottom_sheet.dart';
import '../../../../core/widgets/snack_bar.dart';
import '../provider/shopping_cubit.dart';
import '../provider/shopping_state.dart';
import '../widgets/shopping/ingredient_list_view.dart';
import '../widgets/shopping/recipe_list_view.dart';

class ShoppingPage extends StatelessWidget {
  const ShoppingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ShoppingCubit>()..load(),
      child: const ShoppingView(),
    );
  }
}

class ShoppingView extends StatelessWidget {
  const ShoppingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.deepOrange.shade500],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.shopping_cart,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Danh sách mua sắm',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          BlocBuilder<ShoppingCubit, ShoppingState>(
            builder: (context, state) {
              final isByRecipe = state.viewMode == ShoppingViewMode.byRecipe;
              return Container(
                margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: TextButton.icon(
                  icon: Icon(
                    isByRecipe ? Icons.restaurant_menu : Icons.shopping_basket,
                    size: 18,
                    color: Colors.orange.shade700,
                  ),
                  label: Text(
                    isByRecipe ? 'Món ăn' : 'Nguyên liệu',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () async {
                    await showCustomBottomSheet(context, [
                      BottomSheetOption(
                        icon: Icon(
                          Icons.restaurant_menu,
                          color: Colors.orange.shade700,
                        ),
                        title: "Xem theo món ăn",
                        onTap: () {
                          context
                              .read<ShoppingCubit>()
                              .toggleView(ShoppingViewMode.byRecipe);
                        },
                      ),
                      BottomSheetOption(
                        icon: Icon(
                          Icons.shopping_basket,
                          color: Colors.orange.shade700,
                        ),
                        title: "Xem theo nguyên liệu",
                        onTap: () {
                          context
                              .read<ShoppingCubit>()
                              .toggleView(ShoppingViewMode.byIngredient);
                        },
                      ),
                    ]);
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocListener<ShoppingCubit, ShoppingState>(
          listenWhen: (prev, curr) => curr.error != null,
          listener: (context, state) {
            if (state.error != null) {
              showCustomSnackBar(context, state.error!, isError: true);
            }
          },
          child: BlocBuilder<ShoppingCubit, ShoppingState>(
            builder: (context, state) {
              final isByRecipe = state.viewMode == ShoppingViewMode.byRecipe;
              return isByRecipe
                  ? RecipeListWidget(recipes: state.recipes)
                  : IngredientListWidget(ingredients: state.ingredients);
            },
          ),
        ),
      ),
    );
  }
}