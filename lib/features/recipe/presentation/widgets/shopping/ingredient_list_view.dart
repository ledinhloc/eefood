import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/shopping_ingredient_model.dart';
import '../../provider/shopping_cubit.dart';
import '../ingredient_tile.dart';

class IngredientListWidget extends StatelessWidget {
  final List<ShoppingIngredientModel> ingredients;

  const IngredientListWidget({
    super.key,
    required this.ingredients,
  });

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_basket_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Không có nguyên liệu',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thêm món ăn để có nguyên liệu',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ShoppingCubit>().load(),
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: ingredients.length,
        itemBuilder: (context, index) {
          final ing = ingredients[index];
          return IngredientTile(
            ingredient: ing,
            onToggle: (val) => context.read<ShoppingCubit>().togglePurchased(
              ing,
              val ?? false,
            ),
          );
        },
      ),
    );
  }
}