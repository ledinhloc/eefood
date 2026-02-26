import 'package:eefood/features/recipe/data/models/shopping_item_model.dart';
import 'package:flutter/material.dart';

class ShoppingMessageCard extends StatelessWidget {
  final ShoppingItemModel item;
  const ShoppingMessageCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.recipeTitle != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.recipeTitle!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (item.servings != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${item.servings} phần',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.deepOrange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          ...item.ingredients.map((ingredient) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.deepOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ingredient.ingredientName ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    '${ingredient.quantity ?? ''} ${ingredient.unit ?? ''}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}