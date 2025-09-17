import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:flutter/material.dart';

class RecipeGridCard extends StatelessWidget {
  final List<RecipeModel> recipes;
  const RecipeGridCard({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];

        final String title = (recipe.title ?? recipe.title ?? recipe.toString());
        ImageProvider imageProvider;
        try {
          // nếu model có trường imageUrl (String?)
          final String? url = recipe.imageUrl;
          if (url != null && url.isNotEmpty) {
            imageProvider = NetworkImage(url);
          } else {
            imageProvider = AssetImage("assets/food${(index % 6) + 1}.jpg");
          }
        } catch (e) {
          // nếu RecipeModel không có imageUrl, dùng asset làm fallback
          imageProvider = AssetImage("assets/food${(index % 6) + 1}.jpg");
        }

        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
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
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
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
        );
      },
    );
  }
}
