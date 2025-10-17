import 'package:flutter/material.dart';
import '../../../../recipe/presentation/screens/recipe_detail_page.dart';
import '../../../data/models/post_simple_model.dart';
import '../../../../../core/widgets/user_avatar.dart';

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
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ảnh bài post
            AspectRatio(
              aspectRatio: 1.5,
              child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                  ? Image.network(
                recipe.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 40),
                ),
              )
                  : Container(
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.image, size: 40)),
              ),
            ),

            // Phần nội dung (title + avatar)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 6.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề món ăn
                  Text(
                    recipe.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Avatar + tên người đăng
                  Row(
                    children: [
                      UserAvatar(
                        username: "Loc Dinh Le",
                        url:
                        'https://jbagy.me/wp-content/uploads/2025/03/hinh-anh-cute-avatar-vo-tri-3.jpg',
                        radius: 16, // ⬅️ Phóng to avatar
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Loc Dinh Le",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
