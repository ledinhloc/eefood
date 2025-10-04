import 'package:eefood/features/recipe/presentation/provider/shopping_cubit.dart';
import 'package:eefood/features/recipe/presentation/widgets/ingredient_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_bottom_sheet.dart';
import '../../data/models/shopping_item_model.dart';

class RecipeCard extends StatelessWidget {
  final ShoppingItemModel item;
  const RecipeCard({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* Recipe title*/
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.recipeTitle ?? "Unknown Recipe",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(onPressed: () {
                  showCustomBottomSheet(context, [
                    BottomSheetOption(
                      icon: Icons.edit_note_rounded,
                      title: "Sửa",
                      onTap: () {
                        context.read<ShoppingCubit>().loadByRecipe();
                      },
                    ),
                    BottomSheetOption(
                      icon: Icons.delete_forever,
                      title: "Xóa",
                      onTap: () {
                        context.read<ShoppingCubit>().removeItem(item.id ?? 0);
                      },
                    ),
                  ]);
                }, icon: Icon(Icons.more_vert_sharp))
              ],
            ),
            const SizedBox(height: 8),
            /* Ingredients list*/
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: item.ingredients.length ?? 0,
              itemBuilder: (context, index) {
                final ing = item.ingredients[index];
                return IngredientTile(
                    ingredient: ing,
                    dense: true,
                    onToggle: (val) {
                      context.read<ShoppingCubit>().togglePurchased(ing, val ?? false);
                    },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
