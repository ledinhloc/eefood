import 'package:eefood/features/recipe/presentation/widgets/ingredient_tile.dart';
import 'package:flutter/material.dart';
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
                PopupMenuButton<String>(
                  onSelected: (value) {},
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'remove', child: Text('remove')),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('edit serving'),
                    ),
                  ],
                ),
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
                return IngredientTile(ingredient: ing, dense: true);
              },
            ),
          ],
        ),
      ),
    );
  }
}
