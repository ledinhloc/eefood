import 'package:eefood/features/recipe/data/models/ingredient_model.dart';
import 'package:flutter/material.dart';
import 'ingredient_bottom_sheet.dart';

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
      builder: (context) => IngredientBottomSheet(
        onAddIngredient: (ingredient) {
          setState(() {
            widget.ingredients.add(ingredient);
          });
          widget.onIngredientsUpdated();
        },
        suggestions: _ingredientSuggestions,
      ),
    );
  }

  void _reorderIngredients(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ingredients', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (widget.ingredients.isEmpty)
          const Center(
            child: Text('No ingredients added yet', style: TextStyle(color: Colors.grey)),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.ingredients.length,
            itemBuilder: (context, index) {
              final ingredient = widget.ingredients[index];
              return ListTile(
                key: Key('ingredient_$index'),
                leading: const Icon(Icons.drag_handle),
                title: Text(ingredient.name),
                subtitle: ingredient.quantity != null ? Text('${ingredient.quantity} ${ingredient.unit ?? ''}') : null,
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeIngredient(index),
                ),
              );
            },
            onReorder: _reorderIngredients,
          ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton.icon(
            onPressed: _addIngredient,
            icon: const Icon(Icons.add),
            label: const Text('Add Ingredient'),
          ),
        ),
      ],
    );
  }
}