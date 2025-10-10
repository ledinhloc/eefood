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
        return ListTile(
          leading: ing.ingredient?.image != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              ing.ingredient!.image!,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          )
              : const Icon(Icons.fastfood, color: Colors.orange),
          title: Text(ing.ingredient?.name ?? ''),
          subtitle: Text("${ing.quantity ?? ''} ${ing.unit ?? ''}"),
        );
      },
    );
  }
}
