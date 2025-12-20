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
    final imageSize = dense ? 36.0 : 44.0;
    final isPurchased = ingredient.purchased ?? false;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: dense ? 2 : 4,
        horizontal: dense ? 0 : 4,
      ),
      decoration: BoxDecoration(
        color: isPurchased
            ? Colors.green.shade50
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPurchased
              ? Colors.green.shade200
              : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => onToggle?.call(!isPurchased),
          child: Padding(
            padding: EdgeInsets.all(dense ? 6 : 8),
            child: Row(
              children: [
                // Image
                _buildImage(imageSize, isPurchased),

                SizedBox(width: dense ? 8 : 10),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ingredient.ingredientName ?? 'Unknown',
                        style: TextStyle(
                          fontSize: dense ? 13 : 14,
                          fontWeight: FontWeight.w600,
                          color: isPurchased
                              ? Colors.grey.shade600
                              : Colors.black87,
                          decoration: isPurchased
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((ingredient.quantity != null || ingredient.unit != null) &&
                          ingredient.unit?.isNotEmpty == true) ...[
                        SizedBox(height: dense ? 2 : 3),
                        Row(
                          children: [
                            Icon(
                              Icons.scale_outlined,
                              size: 12,
                              color: isPurchased
                                  ? Colors.grey.shade500
                                  : Colors.orange.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${ingredient.quantity ?? ''} ${ingredient.unit ?? ''}',
                              style: TextStyle(
                                fontSize: dense ? 11 : 12,
                                color: isPurchased
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(width: dense ? 6 : 8),

                // Checkbox
                _buildCheckbox(isPurchased),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(double size, bool isPurchased) {
    if (ingredient.image == null || ingredient.image!.isEmpty) {
      return _fallbackIcon(size, isPurchased);
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            ingredient.image!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _fallbackIcon(size, isPurchased),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _loadingPlaceholder(size);
            },
          ),
        ),
        if (isPurchased)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
          ),
      ],
    );
  }

  Widget _buildCheckbox(bool isPurchased) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isPurchased
              ? Colors.green.shade400
              : Colors.grey.shade400,
          width: 2,
        ),
        color: isPurchased
            ? Colors.green.shade400
            : Colors.transparent,
      ),
      child: isPurchased
          ? const Icon(
        Icons.check,
        size: 16,
        color: Colors.white,
      )
          : null,
    );
  }

  Widget _fallbackIcon(double size, bool isPurchased) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPurchased
              ? [Colors.grey.shade300, Colors.grey.shade400]
              : [Colors.orange.shade100, Colors.orange.shade200],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPurchased
              ? Colors.grey.shade400
              : Colors.orange.shade300,
          width: 1,
        ),
      ),
      child: Icon(
        Icons.restaurant,
        color: isPurchased
            ? Colors.grey.shade600
            : Colors.orange.shade700,
        size: size * 0.5,
      ),
    );
  }

  Widget _loadingPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: SizedBox(
        width: size * 0.4,
        height: size * 0.4,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.orange.shade400,
        ),
      ),
    );
  }
}