import 'package:flutter/material.dart';

import '../../data/models/shopping_ingredient_model.dart';

class IngredientTile extends StatelessWidget {
  final ShoppingIngredientModel ingredient;
  final void Function(bool?)? onToggle;
  final bool dense;
  const IngredientTile({
    required this.ingredient,
    this.onToggle,
    this.dense = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: dense
          ? const EdgeInsets.symmetric(horizontal: 4)
          : const EdgeInsets.symmetric(horizontal: 12),
      leading: ingredient.image != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                ingredient.image!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            )
          : const SizedBox(width: 40, height: 40),
      title: Text(
        ingredient.ingredientName ?? 'Unknown',
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(
        '${ingredient.quantity ?? ''} ${ingredient.unit ?? ''}',
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: Checkbox(
        value: ingredient.purchased ?? false,
        onChanged: onToggle,
      ),
    );
  }
}
