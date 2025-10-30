import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eefood/core/di/injection.dart';
import '../../../../../core/widgets/custom_bottom_sheet.dart';
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeDetailPage(recipeId: post.recipeId!),
          ),
        );
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
                // Nút menu
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onPressed: () {
                      showCustomBottomSheet(context, [
                        BottomSheetOption(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          title: "Sửa nội dung",
                          onTap: () {
                            _showEditDialog(context, postCubit, post);
                          },
                        ),
                        BottomSheetOption(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          title: "Xóa bài đăng",
                          onTap: () {
                            postCubit.deletePost(context, post.id);
                          },
                        ),
                      ]);
                    },
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

                    // // ✅ Hiển thị content ở đây
                    // if (post.content != null && post.content!.isNotEmpty)
                    //   Text(
                    //     post.content!,
                    //     style: const TextStyle(fontSize: 13),
                    //     maxLines: 2,
                    //     overflow: TextOverflow.ellipsis,
                    //   ),

                    const SizedBox(height: 6),
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

  /// ✅ Hàm hiển thị dialog chỉnh sửa content
  void _showEditDialog(
      BuildContext context, PostCubit postCubit, PostPublishModel post) {
    final controller = TextEditingController(text: post.content ?? "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Chỉnh sửa nội dung"),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Nhập nội dung mới...",
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Hủy"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text("Lưu"),
            onPressed: () {
              final newContent = controller.text.trim();
              if (newContent.isNotEmpty) {
                postCubit.updatePost(context, post.id, newContent);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
