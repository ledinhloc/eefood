import 'package:flutter/material.dart';
import '../../../recipe/presentation/screens/recipe_detail_page.dart';
import '../../data/models/post_simple_model.dart';

class PostSummaryCard extends StatelessWidget {
  final PostSimpleModel recipe;

  const PostSummaryCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeDetailPage(recipeId: recipe.recipeId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh bài post
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                  ? Image.network(
                      recipe.imageUrl!,
                      fit: BoxFit.cover,
                      height: 130,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        height: 130,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      ),
                    )
                  : Container(
                      height: 130,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.image)),
                    ),
            ),
            // Thông tin tóm tắt
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                recipe.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              children: [
                const CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.deepPurple,
                  child: Text(
                    "N",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  "Nguyen Van",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
