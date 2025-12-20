import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/recipe/presentation/provider/shopping_cubit.dart';
import 'package:eefood/features/recipe/presentation/widgets/ingredient_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_bottom_sheet.dart';
import '../../data/models/shopping_item_model.dart';
import '../screens/recipe_detail_page.dart';

class RecipeCard extends StatelessWidget {
  final ShoppingItemModel item;
  const RecipeCard({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange.shade100, width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.orange.shade50.withOpacity(0.3),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Recipe Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade400,
                          Colors.deepOrange.shade500,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title & Serving
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.recipeTitle ?? "Unknown Recipe",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 16,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item.servings ?? 1} khẩu phần',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // More Button
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.grey.shade700,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      await showCustomBottomSheet(context, [
                        BottomSheetOption(
                          icon: Icon(
                            Icons.visibility_outlined,
                            color: Colors.orange.shade700,
                          ),
                          title: "Xem món ăn",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RecipeDetailPage(recipeId: item.recipeId!),
                              ),
                            );
                          },
                        ),
                        BottomSheetOption(
                          icon: Icon(
                            Icons.edit_outlined,
                            color: Colors.orange.shade700,
                          ),
                          title: "Cập nhật khẩu phần",
                          onTap: () async {
                            final newServing = await _showDialogUpdateServing(
                              context,
                              item,
                            );
                            if (newServing != null) {
                              context
                                  .read<ShoppingCubit>()
                                  .updateServings(item.id!, newServing);
                            }
                          },
                        ),
                        BottomSheetOption(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          title: "Xóa khỏi danh sách",
                          onTap: () {
                            context
                                .read<ShoppingCubit>()
                                .removeItem(item.id ?? 0);
                          },
                        ),
                      ]);
                    },
                  ),
                ],
              ),

              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Divider(
                  color: Colors.orange.shade200,
                  height: 1,
                ),
              ),

              // Ingredients Count Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_basket_outlined,
                      size: 14,
                      color: Colors.orange.shade800,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.ingredients.length} nguyên liệu',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Ingredients List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: item.ingredients.length,
                itemBuilder: (context, index) {
                  final ing = item.ingredients[index];
                  return IngredientTile(
                    ingredient: ing,
                    dense: true,
                    onToggle: (val) {
                      context.read<ShoppingCubit>().togglePurchased(
                        ing,
                        val ?? false,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int?> _showDialogUpdateServing(
      BuildContext context,
      ShoppingItemModel recipe,
      ) async {
    final controller = TextEditingController(
      text: recipe.servings?.toString() ?? "1",
    );

    return showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.deepOrange.shade500],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.people, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              "Cập nhật khẩu phần",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: "Số khẩu phần",
            prefixIcon: const Icon(Icons.people_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.orange.shade400,
                width: 2,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              "Hủy",
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                Navigator.pop(dialogContext, value);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade500,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Lưu",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}