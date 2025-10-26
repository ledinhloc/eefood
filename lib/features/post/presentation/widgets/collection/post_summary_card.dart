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
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 1.5,
                  child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                      ? Image.network(
                          recipe.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image, size: 40),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      Row(
                        children: [
                          UserAvatar(
                            username: recipe.username,
                            url: recipe.avatarUrl,
                            radius: 16, //  Phóng to avatar
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              recipe.username,
                              style: const TextStyle(fontSize: 13),
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

            // Nút 3 chấm
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {
                  showCustomBottomSheet(context, [
                    BottomSheetOption(
                      icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.orange),
                      title: 'Thêm vào danh sách mua sắm',
                      onTap: () => getIt<ShoppingCubit>().addRecipe(recipe.recipeId),
                    ),
                    BottomSheetOption(
                      icon: const Icon(Icons.bookmark_add, color: Colors.blue),
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
                          builder: (_) =>
                              AddToCollectionSheet(postId: recipe.postId),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}