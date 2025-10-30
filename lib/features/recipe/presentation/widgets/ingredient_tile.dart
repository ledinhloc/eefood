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
    const double imageSize = 50;

    Widget buildImage() {
      if (ingredient.image == null || ingredient.image!.isEmpty) {
        return _fallbackIcon(imageSize);
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          ingredient.image!,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _fallbackIcon(imageSize),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _loadingPlaceholder(imageSize);
          },
        ),
      );
    }

    return ListTile(
      contentPadding: dense
          ? const EdgeInsets.symmetric(horizontal: 0)
          : const EdgeInsets.symmetric(horizontal: 5),
      leading: buildImage(),
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

  Widget _fallbackIcon(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.image_not_supported, color: Colors.grey),
  );

  Widget _loadingPlaceholder(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(8),
    ),
    alignment: Alignment.center,
    child: const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  );
}