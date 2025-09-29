import 'package:eefood/app_routes.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:eefood/features/recipe/domain/entities/recipe.dart';
import 'package:flutter/material.dart';

class RecipeGridCard extends StatelessWidget {
  final RecipeModel recipe;
  final int index;
  final VoidCallback? onRefresh;
  const RecipeGridCard({super.key, required this.recipe, required this.index, this.onRefresh,});

  @override
  Widget build(BuildContext context) {
    final String title = recipe.title ?? 'Untitled';
    ImageProvider imageProvider;
    try {
      final url = recipe.imageUrl;
      if (url != null && url.isNotEmpty) {
        imageProvider = NetworkImage(url);
      } else {
        imageProvider = AssetImage("assets/food${(index % 6) + 1}.jpg");
      }
    } catch (_) {
      imageProvider = AssetImage("assets/food${(index % 6) + 1}.jpg");
    }

    return GestureDetector(
      onTap: () async {
        if (recipe.id == null) {
          showCustomSnackBar(context, "Cannot edit recipe: Invalid recipe ID");
          return;
        }
        print(recipe.toJson());
        final result = await Navigator.pushNamed(
          context,
          AppRoutes.recipeCrudPage,
          arguments: {'initialRecipe': recipe, 'isCreate': false},
        );
        if (result == true) {
          // Kích hoạt làm mới danh sách
          onRefresh?.call();
        }
      },
      child: Stack(
        children: [
          Container(
            key: ValueKey(recipe.id ?? index),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.edit, size: 16, color: Colors.white),
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
