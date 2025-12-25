import 'package:eefood/core/widgets/custom_bottom_sheet.dart';
import 'package:eefood/features/recipe/presentation/provider/post_cubit.dart';
import 'package:eefood/features/recipe/presentation/widgets/published/edit_post_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../../app_routes.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/widgets/snack_bar.dart';
import '../../../data/models/post_publish_model.dart';

import '../../../data/models/post_publish_model.dart';
import '../../../domain/repositories/recipe_repository.dart';
import '../../provider/post_state.dart';

extension PostStatusUI on PostStatus {
  Color get color {
    switch (this) {
      case PostStatus.pending:
        return const Color(0xFFFFA726);
      case PostStatus.editedPending:
        return const Color(0xFFFFA726);
      case PostStatus.approved:
        return const Color(0xFF66BB6A);
      case PostStatus.rejected:
        return const Color(0xFFEF5350);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case PostStatus.pending:
        return const Color(0xFFFFF3E0);
      case PostStatus.editedPending:
        return const Color(0xFFFFF3E0);
      case PostStatus.approved:
        return const Color(0xFFE8F5E9);
      case PostStatus.rejected:
        return const Color(0xFFFFEBEE);
    }
  }

  IconData get icon {
    switch (this) {
      case PostStatus.pending:
        return Icons.schedule;
      case PostStatus.editedPending:
        return Icons.edit;
      case PostStatus.approved:
        return Icons.check_circle;
      case PostStatus.rejected:
        return Icons.cancel;
    }
  }

  String get displayText {
    switch (this) {
      case PostStatus.pending:
        return 'Đang chờ duyệt';
      case PostStatus.editedPending:
        return 'Đang chờ duyệt lại';
      case PostStatus.approved:
        return 'Đã duyệt';
      case PostStatus.rejected:
        return 'Bị từ chối';
    }
  }
}

class PublishedList extends StatelessWidget {
  const PublishedList({super.key});

  @override
  Widget build(BuildContext context) {
    final postCubit = getIt<PostCubit>();

    return BlocBuilder<PostCubit, PostState>(
      bloc: postCubit,
      builder: (context, state) {
        final posts = state.posts;

        return RefreshIndicator(
          onRefresh: () async {
            await postCubit.fetchPublishedPosts();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return PublishedPostCard(post: posts[index]);
            },
          ),
        );
      },
    );
  }
}


class PublishedPostCard extends StatelessWidget {
  final PostPublishModel post;
  final postCubit = getIt<PostCubit>();

  PublishedPostCard({super.key, required this.post});

  Future<void> _onEditRecipe(BuildContext context) async {
    if (post.recipeId == null) {
      showCustomSnackBar(
        context,
        "Công thức không hợp lệ",
        isError: true,
      );
      return;
    }

    try {
      final recipeRepo = getIt<RecipeRepository>();
      final recipe = await recipeRepo.getRecipeById(post.recipeId!);

      final result = await Navigator.pushNamed(
        context,
        AppRoutes.recipeCrudPage,
        arguments: {
          'initialRecipe': recipe,
          'isCreate': false,
        },
      );

      // Edit xong → refresh list post
      if (result == true) {
        postCubit.fetchPublishedPosts();
      }
    } catch (e, stack) {
      debugPrint('Edit recipe error: $e');
      debugPrintStack(stackTrace: stack);
      showCustomSnackBar(
        context,
        "Không thể tải công thức",
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = post.status;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section với Status Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: post.imageUrl != null
                    ? Image.network(
                        post.imageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              // Status Badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: status.backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: status.color, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(status.icon, size: 16, color: status.color),
                      const SizedBox(width: 4),
                      Text(
                        status.displayText,
                        style: TextStyle(
                          color: status.color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () async {
                    await showCustomBottomSheet(context, [
                      BottomSheetOption(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        title: "Chỉnh sửa bài viết",
                        onTap: () {
                          _showEditDialog(context, postCubit, post);
                        },
                      ),
                      BottomSheetOption(
                        icon: const Icon(Icons.restaurant_menu, color: Colors.orange),
                        title: "Sửa công thức",
                        onTap: () => _onEditRecipe(context),
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
                  icon: Icon(Icons.more_vert),
                ),
              ),
            ],
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Content
                Text(
                  post.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Recipe Info Row
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    if (post.difficulty != null)
                      _buildInfoChip(
                        Icons.signal_cellular_alt,
                        post.difficulty!,
                        const Color(0xFFFF6B6B),
                      ),
                    if (post.prepTime != null)
                      _buildInfoChip(
                        Icons.timer_outlined,
                        post.prepTime!,
                        const Color(0xFF4ECDC4),
                      ),
                    if (post.cookTime != null)
                      _buildInfoChip(
                        Icons.local_fire_department_outlined,
                        post.cookTime!,
                        const Color(0xFFFFBE0B),
                      ),
                    if (post.location != null)
                      _buildInfoChip(
                        Icons.location_on_outlined,
                        post.location!,
                        const Color(0xFF95E1D3),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Stats and Time Row
                Row(
                  children: [
                    // Reactions
                    _buildStatItem(
                      Icons.favorite_border,
                      post.countReaction ?? 0,
                      const Color(0xFFFF6B6B),
                    ),
                    const SizedBox(width: 16),
                    // Comments
                    _buildStatItem(
                      Icons.chat_bubble_outline,
                      post.countComment ?? 0,
                      const Color(0xFF4ECDC4),
                    ),
                    const Spacer(),
                    // Time ago
                    if (post.createdAt != null)
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeago.format(post.createdAt!, locale: 'vi'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.grey[200],
      child: Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, int count, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  void _showEditDialog(
      BuildContext context,
      PostCubit postCubit,
      PostPublishModel post,
      ) {
    final titleController = TextEditingController(text: post.title);
    final contentController = TextEditingController(text: post.content);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditPostDialog(post: post, postCubit: postCubit),
    );
  }
}
