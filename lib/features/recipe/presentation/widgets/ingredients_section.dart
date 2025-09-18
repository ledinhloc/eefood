import 'dart:math';
import 'package:flutter/material.dart';
import 'ingredient_bottom_sheet.dart';
import 'package:eefood/features/recipe/data/models/ingredient_model.dart';

class IngredientsSection extends StatefulWidget {
  final List<IngredientModel> ingredients;
  final VoidCallback onIngredientsUpdated;

  const IngredientsSection({
    Key? key,
    required this.ingredients,
    required this.onIngredientsUpdated,
  }) : super(key: key);

  @override
  _IngredientsSectionState createState() => _IngredientsSectionState();
}

class _IngredientsSectionState extends State<IngredientsSection> {
  final List<String> _ingredientSuggestions = [
    'Flour',
    'Sugar',
    'Salt',
    'Butter',
    'Eggs',
    'Milk',
    'Water',
    'Oil',
    'Pepper',
    'Garlic',
    'Onion',
    'Tomato',
    'Rice',
    'Pasta',
    'Chicken',
    'Beef',
    'Fish',
    'Cheese',
  ];

  void _addIngredient() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: IngredientBottomSheet(
          onSaveIngredient: (ingredient, {int? index}) {
            setState(() {
              widget.ingredients.add(ingredient);
            });
            widget.onIngredientsUpdated();
          },
          suggestions: _ingredientSuggestions,
        ),
      ),
    );
  }

  void _editIngredient(int index) {
    final ingredient = widget.ingredients[index];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => IngredientBottomSheet(
        suggestions: _ingredientSuggestions,
        editingIngredient: ingredient,
        editingIndex: index,
        onSaveIngredient: (updatedIngredient, {int? index}) {
          if (index != null) {
            setState(() {
              widget.ingredients[index] = updatedIngredient;
            });
            widget.onIngredientsUpdated();
          }
        },
      ),
    );
  }

  void _reorderIngredients(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final IngredientModel item = widget.ingredients.removeAt(oldIndex);
      widget.ingredients.insert(newIndex, item);
    });
    widget.onIngredientsUpdated();
  }

  void _removeIngredient(int index) {
    setState(() {
      widget.ingredients.removeAt(index);
    });
    widget.onIngredientsUpdated();
  }

  @override
  Widget build(BuildContext context) {
    const double itemHeight = 64.0;
    const double maxListHeight = 300.0;
    final double listHeight = min(
      widget.ingredients.length * itemHeight,
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
        if (widget.ingredients.isEmpty)
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
              children: List.generate(widget.ingredients.length, (index) {
                final ingredient = widget.ingredients[index];
                final displayText =
                    '${ingredient.name} ${ingredient.quantity ?? ''}${ingredient.unit ?? ''}';

                return Card(
                  key: ValueKey('ingredient_${index}_${ingredient.name}'),
                  margin: const EdgeInsets.only(bottom: 5),
                  color: Colors.white,
                  child: ListTile(
                    leading: const Icon(Icons.drag_handle),
                    title: Text(displayText.trim()),
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
            icon: const Icon(Icons.add, color: Colors.white,),
            label: const Text('Add Ingredient', style: TextStyle(color: Colors.white),),
          ),
        ),
      ],
    );
  }
}
