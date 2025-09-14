import 'package:eefood/features/recipe/data/models/ingredient_model.dart';
import 'package:flutter/material.dart';


class IngredientBottomSheet extends StatefulWidget {
  final Function(IngredientModel) onAddIngredient;
  final List<String> suggestions;

  const IngredientBottomSheet({
    Key? key,
    required this.onAddIngredient,
    required this.suggestions,
  }) : super(key: key);

  @override
  _IngredientBottomSheetState createState() => _IngredientBottomSheetState();
}

class _IngredientBottomSheetState extends State<IngredientBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Ingredient', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              return widget.suggestions.where((String option) {
                return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (String selection) {
              _nameController.text = selection;
            },
            fieldViewBuilder: (BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted) {
              return TextFormField(
                controller: textEditingController,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: 'Ingredient Name',
                  border: OutlineInputBorder(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _quantityController,
            decoration: const InputDecoration(
              labelText: 'Quantity (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  if (_nameController.text.isNotEmpty) {
                    widget.onAddIngredient(
                      IngredientModel(
                        name: _nameController.text,
                        quantity: int.tryParse(_quantityController.text.trim()),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}