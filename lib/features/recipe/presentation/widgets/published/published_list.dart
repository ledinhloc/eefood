import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eefood/core/di/injection.dart';
import '../../provider/post_cubit.dart';
import '../../../../recipe/data/models/post_publish_model.dart';
import '../../screens/recipe_detail_page.dart';

class PublishedList extends StatelessWidget {
  final List<PostPublishModel> posts;

  const PublishedList({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {

    return RefreshIndicator(
      color: Colors.red,
      onRefresh: () async {
        // Gọi Cubit để load lại danh sách bài viết
        await getIt<PostCubit>().fetchPublishedPosts();
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        physics: const AlwaysScrollableScrollPhysics(), // bắt buộc để refresh hoạt động
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return _PostCard(post: posts[index]);
        },
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final PostPublishModel post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final postCubit = getIt<PostCubit>();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (post.recipeId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecipeDetailPage(recipeId: post.recipeId!),
            ),
          );
        } else {
          showCustomSnackBar(context, "Không tìm thấy công thức", isError: true);
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh bài viết
            Stack(
              children: [
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      post.imageUrl ??
                          'https://cdn-icons-png.flaticon.com/512/147/147144.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.broken_image_outlined,
                              size: 48, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
                // Menu update/delete
                Positioned(
                  top: 4,
                  right: 4,
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) {
                      if (value == "update") {
                        postCubit.updatePost(context, post.id, post.title ?? "");
                      } else if (value == "delete") {
                        postCubit.deletePost(context, post.id);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: "update", child: Text("Cập nhật")),
                      PopupMenuItem(value: "delete", child: Text("Xóa")),
                    ],
                  ),
                ),
              ],
            ),

            // Nội dung bài viết
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title ?? "Không có tiêu đề",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Chuẩn bị: ${post.prepTime ?? 'N/A'} | Nấu: ${post.cookTime ?? 'N/A'}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            post.difficulty?.toUpperCase() ?? "EASY",
                            style: const TextStyle(
                                fontSize: 10, color: Colors.green),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(post.location ?? "Không xác định",
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.favorite_border,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${post.countReaction ?? 0}',
                            style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 12),
                        const Icon(Icons.comment,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${post.countComment ?? 0}',
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}