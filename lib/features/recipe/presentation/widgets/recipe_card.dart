import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/recipe/presentation/provider/shopping_cubit.dart';
import 'package:eefood/features/recipe/presentation/widgets/ingredient_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_bottom_sheet.dart';
import '../../data/models/shopping_item_model.dart';

class RecipeCard extends StatelessWidget {
  final ShoppingItemModel item;
  const RecipeCard({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* Recipe title*/
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.recipeTitle ?? "Unknown Recipe",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(onPressed: () {
                  showCustomBottomSheet(context, [
                    BottomSheetOption(
                      icon: Icon(Icons.arrow_right_alt),
                      title: "Xem món ăn",
                      onTap: () {
                        showCustomSnackBar(context, 'Xem mon ăn ${item.recipeTitle}');
                      },
                    ),
                    BottomSheetOption(
                      icon: Icon(Icons.edit_note_rounded),
                      title: "Cập nhật khẩu phần",
                      onTap: () async {
                        final newServing = await _showDialogUpdateServing(context, item);
                        if(newServing != null){
                          context.read<ShoppingCubit>().updateServings(item.id!, newServing);
                        }
                      },
                    ),
                    BottomSheetOption(
                      icon: Icon(Icons.delete_forever),
                      title: "Xóa khỏi danh sách",
                      onTap: () {
                        context.read<ShoppingCubit>().removeItem(item.id ?? 0);
                      },
                    ),
                  ]);
                }, icon: Icon(Icons.more_vert_sharp))
              ],
            ),
            const SizedBox(height: 0),
            /* Ingredients list*/
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: item.ingredients.length ?? 0,
              itemBuilder: (context, index) {
                final ing = item.ingredients[index];
                return IngredientTile(
                    ingredient: ing,
                    dense: true,
                    onToggle: (val) {
                      context.read<ShoppingCubit>().togglePurchased(ing, val ?? false);
                    },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<int?> _showDialogUpdateServing(BuildContext context, ShoppingItemModel recipe) async{
    final newServing = await showDialog<int>(context: context, builder: (context){
      final controller = TextEditingController(
        text: recipe.servings?.toString() ?? "1",
      );

      return AlertDialog(
        title: const Text("Cập nhật khẩu phần"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Số khẩu phần",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                Navigator.pop(context, value);
              }
            },
            child: const Text("Lưu"),
          ),
        ],
      );
    });
    return newServing;
  }
}
