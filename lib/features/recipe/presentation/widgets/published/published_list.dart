
import 'package:flutter/material.dart';
import 'package:eefood/core/di/injection.dart';

import '../../../../recipe/data/models/post_publish_model.dart';
import '../../provider/post_cubit.dart';

class PublishedList extends StatelessWidget {
  final List<PostPublishModel> posts;

  const PublishedList({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 cột như hình
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return _PostCard(post: posts[index]);
      },
    );
  }
}

class _PostCard extends StatelessWidget {
  final PostPublishModel post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final postCubit = getIt<PostCubit>();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh + status
          Stack(
            children: [
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.pink[100],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: const Center(child: Icon(Icons.image_outlined, size: 48)),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "Published",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == "update") {
                      postCubit.updatePost(context, post.id, post.title ?? "");
                    } else if (value == "delete") {
                      postCubit.deletePost(context, post.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: "update", child: Text("Update")),
                    const PopupMenuItem(value: "delete", child: Text("Delete")),
                  ],
                ),
              ),
            ],
          ),

          // Nội dung
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),

                // Thời gian nấu
                Text(
                  "Prep: ${post.prepTime ?? 'N/A'} | Cook: ${post.cookTime ?? 'N/A'}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 4),

                // Độ khó + địa điểm
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        post.difficulty?.toUpperCase() ?? "EASY",
                        style: const TextStyle(fontSize: 10, color: Colors.green),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(post.location ?? "Unknown", style: const TextStyle(fontSize: 12)),
                  ],
                ),

                const SizedBox(height: 6),

                // Like + comment
                Row(
                  children: [
                    const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${post.countReaction ?? 0}', style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 12),
                    const Icon(Icons.comment, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${post.countComment ?? 0}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
