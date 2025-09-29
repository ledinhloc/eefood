import 'dart:math';
import 'package:eefood/features/recipe/data/models/recipe_Ingredient_model.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'ingredient_bottom_sheet.dart';
import 'package:eefood/features/recipe/data/models/ingredient_model.dart';

class IngredientsSection extends StatefulWidget {
  const IngredientsSection({Key? key}) : super(key: key);

  @override
  _IngredientsSectionState createState() => _IngredientsSectionState();
}

class _IngredientsSectionState extends State<IngredientsSection> {
  void _addIngredient() {
    final cubit = context.read<RecipeCrudCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return BlocProvider.value(
          value: cubit,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: IngredientBottomSheet(
              onSaveIngredient: (ingredient, {int? index}) {
                if (index == null) {
                  context.read<RecipeCrudCubit>().addIngredient(ingredient);
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _editIngredient(int index) {
    final cubit = context.read<RecipeCrudCubit>();
    final ingredient = cubit.state.ingredients[index];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return BlocProvider.value(
          value: cubit,
          child: IngredientBottomSheet(
            editingIngredient: ingredient,
            editingIndex: index,
            onSaveIngredient: (updatedIngredient, {int? index}) {
              if (index != null) {
                context.read<RecipeCrudCubit>().updateIngredients(
                  index,
                  updatedIngredient,
                );
              }
            },
          ),
        );
      },
    );
  }

  void _reorderIngredients(int oldIndex, int newIndex) {
    final cubit = context.read<RecipeCrudCubit>();
    if (cubit.state.ingredients.length <= 1) {
      return;
    }
    cubit.reorderIngredients(oldIndex, newIndex);
  }

  void _removeIngredient(int index) {
    final cubit = context.read<RecipeCrudCubit>();
    cubit.removeIngredient(index);
  }

  Widget _buildIngredientCard(RecipeIngredientModel ingredient, int index) {
    final displayText =
        '${ingredient.ingredient!.name} ${ingredient.quantity ?? ''}${ingredient.unit ?? ''}';

    return Card(
      key: ValueKey('ingredient_${index}_${ingredient.ingredient!.name}'),
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 4, // Tăng độ đổ bóng
      shadowColor: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Drag handle
            const Icon(Icons.drag_handle, color: Colors.grey, size: 20),
            const SizedBox(width: 8),

            // Hình ảnh ingredient
            if (ingredient.ingredient?.image != null &&
                ingredient.ingredient!.image!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  ingredient.ingredient!.image!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.fastfood,
                      size: 24,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[100]!),
                ),
                child: const Icon(
                  Icons.fastfood,
                  size: 24,
                  color: Colors.orange,
                ),
              ),

            const SizedBox(width: 12),

            // Thông tin ingredient
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ingredient.ingredient!.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (ingredient.quantity != null || ingredient.unit != null)
                    Text(
                      '${ingredient.quantity ?? ''}${ingredient.unit ?? ''}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Action buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black, size: 20),
                  onPressed: () => _editIngredient(index),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.black, size: 20),
                  onPressed: () => _removeIngredient(index),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RecipeCrudCubit>().state;
    final ingredients = state.ingredients;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingredients',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        if (ingredients.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Center(
              child: Text(
                'No ingredients added yet',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          )
        else
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: _reorderIngredients,
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                final ingredient = ingredients[index];
                return _buildIngredientCard(ingredient, index);
              },
            ),
          ),

        const SizedBox(height: 16),
        Center(
          child: ElevatedButton.icon(
            onPressed: _addIngredient,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add Ingredient',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
