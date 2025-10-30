import 'package:flutter/material.dart';

class InstructionsTab extends StatelessWidget {
  final dynamic recipe;
  const InstructionsTab({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
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
                return const Icon(Icons.image_not_supported,
                    color: Colors.grey, size: 40);
              },
            )
                : const Icon(Icons.image_not_supported,
                color: Colors.grey, size: 40),
          ),
          title: Text(ing.ingredient?.name ?? ''),
          subtitle: Text("${ing.quantity ?? ''} ${ing.unit ?? ''}"),
        );
      },
    );
  }
}