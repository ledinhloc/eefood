import 'dart:math';
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
    cubit.reorderIngredients(oldIndex, newIndex);
  }

  void _removeIngredient(int index) {
    final cubit = context.read<RecipeCrudCubit>();
    cubit.removeIngredient(index);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RecipeCrudCubit>().state;
    final ingredients = state.ingredients;

    const double itemHeight = 64.0;
    const double maxListHeight = 300.0;
    final double listHeight = min(
      ingredients.length * itemHeight,
      maxListHeight,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingredients',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (ingredients.isEmpty)
          const Center(
            child: Text(
              'No ingredients added yet',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          SizedBox(
            height: listHeight,
            child: ReorderableListView(
              buildDefaultDragHandles: true,
              onReorder: _reorderIngredients,
              children: List.generate(ingredients.length, (index) {
                final ingredient = ingredients[index];
                final displayText =
                    '${ingredient.ingredient!.name} ${ingredient.quantity ?? ''}${ingredient.unit ?? ''}';

                return Card(
                  key: ValueKey(
                    'ingredient_${index}_${ingredient.ingredient!.name}',
                  ),
                  margin: const EdgeInsets.only(bottom: 5),
                  color: Colors.white,
                  child: ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.drag_handle, color: Colors.grey),
                        if (ingredient.ingredient?.image != null &&
                            ingredient.ingredient!.image!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              ingredient.ingredient!.image!,
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.image_not_supported,
                                size: 24,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        else
                          const Icon(
                            Icons.fastfood,
                            size: 28,
                            color: Colors.orange,
                          ),
                        const SizedBox(width: 6),
                  
                      ],
                    ),
                    title: Text(
                      displayText.trim(),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeIngredient(index),
                    ),
                    onTap: () => _editIngredient(index),
                  ),
                );
              }),
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
