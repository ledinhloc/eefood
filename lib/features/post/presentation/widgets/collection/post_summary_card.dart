import 'package:eefood/features/post/data/models/post_collection_model.dart';
import 'package:flutter/material.dart';
import '../../../../../core/di/injection.dart';
import '../../../../recipe/presentation/provider/shopping_cubit.dart';
import '../../../../recipe/presentation/screens/recipe_detail_page.dart';
import '../../../../../core/widgets/user_avatar.dart';

import 'package:eefood/core/widgets/custom_bottom_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../provider/collection_cubit.dart';
import 'add_to_collection_sheet.dart';

class PostSummaryCard extends StatelessWidget {
  final PostCollectionModel recipe;
  final int? currentCollectionId;

  const PostSummaryCard({
    super.key,
    required this.recipe,
    this.currentCollectionId,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = getIt<CollectionCubit>();
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
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  Phần hình ảnh với overlay gradient
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Hình ảnh món ăn
                  recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                      ? Image.network(
                    recipe.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.restaurant,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  )
                      : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.orange[100]!,
                          Colors.orange[50]!,
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 48,
                      color: Colors.orange[300],
                    ),
                  ),

                  // Gradient overlay từ dưới lên
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Nút 3 chấm với backdrop blur
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () async {
                            await showCustomBottomSheet(context, [
                              BottomSheetOption(
                                icon: const Icon(Icons.add_shopping_cart_rounded,
                                    color: Colors.orange),
                                title: 'Thêm vào danh sách nguyên liệu',
                                onTap: () => getIt<ShoppingCubit>()
                                    .addRecipe(recipe.recipeId),
                              ),
                              BottomSheetOption(
                                icon: const Icon(Icons.bookmark_add,
                                    color: Colors.blue),
                                title: 'Lưu vào bộ sưu tập khác',
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    builder: (_) => AddToCollectionSheet(
                                        postId: recipe.postId),
                                  );
                                },
                              ),
                              if (currentCollectionId != null)
                                BottomSheetOption(
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    color: Colors.red,
                                  ),
                                  title: 'Xóa khỏi bộ sưu tập này',
                                  onTap: () async {
                                    await cubit.removePostFromCollection(
                                      currentCollectionId!,
                                      recipe.postId,
                                    );
                                  },
                                ),
                            ]);
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.more_vert,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //  Phần thông tin
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tiêu đề món ăn
                    Text(
                      recipe.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.3,
                        letterSpacing: -0.2,
                      ),
                    ),

                    // Thông tin người đăng
                    Row(
                      children: [
                        UserAvatar(
                          username: recipe.username,
                          url: recipe.avatarUrl,
                          radius: 12,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            recipe.username,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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