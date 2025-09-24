  import 'package:dropdown_search/dropdown_search.dart';
  import 'package:eefood/core/di/injection.dart';
  import 'package:eefood/features/recipe/data/models/ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_Ingredient_model.dart';
  import 'package:eefood/features/recipe/domain/usecases/recipe_usecases.dart';
  import 'package:eefood/features/recipe/presentation/widgets/custom_dropdown.dart';
  import 'package:flutter/material.dart';

  class IngredientBottomSheet extends StatefulWidget {
    final Function(RecipeIngredientModel, {int? index}) onSaveIngredient;
    final RecipeIngredientModel? editingIngredient;
    final int? editingIndex;

    const IngredientBottomSheet({
      Key? key,
      required this.onSaveIngredient,
      this.editingIngredient,
      this.editingIndex,
    }) : super(key: key);

    @override
    _IngredientBottomSheetState createState() => _IngredientBottomSheetState();
  }

  class _IngredientBottomSheetState extends State<IngredientBottomSheet> {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _quantityController = TextEditingController();
    final TextEditingController _unitController = TextEditingController();
    final Ingredients _ingredientsUsecase = getIt<Ingredients>();

    @override
    void initState() {
      super.initState();
      if (widget.editingIngredient != null) {
        _nameController.text = widget.editingIngredient!.ingredient!.name;
        if (widget.editingIngredient!.quantity != null) {
          _quantityController.text = widget.editingIngredient!.quantity!
              .toString();
        }
        if (widget.editingIngredient!.unit != null) {
          _unitController.text = widget.editingIngredient!.unit!;
        }
      }
    }

    /// Hàm chuyển đổi nếu người dùng nhập text phân số
    double? _parseQuantity(String input) {
      input = input.trim();
      if (input.contains("/")) {
        final parts = input.split("/");
        if (parts.length == 2) {
          final num? numerator = num.tryParse(parts[0]);
          final num? denominator = num.tryParse(parts[1]);
          if (numerator != null && denominator != null && denominator != 0) {
            return numerator / denominator;
          }
        }
      }
      return double.tryParse(input);
    }

    void _increaseQuantity() {
      final currentText = _quantityController.text.trim();
      final value = _parseQuantity(currentText);
      if (value != null) {
        double newValue = value + 1;
        _quantityController.text = newValue % 1 == 0
            ? newValue.toInt().toString()
            : newValue.toString();
      } else if (currentText.isEmpty) {
        _quantityController.text = "1";
      }
    }

    void _decreaseQuantity() {
      final currentText = _quantityController.text.trim();
      final value = _parseQuantity(currentText);
      if (value != null) {
        double newValue = value - 1;
        if (newValue >= 0) {
          _quantityController.text = newValue % 1 == 0
              ? newValue.toInt().toString()
              : newValue.toString();
        }
      }
    }

    @override
    Widget build(BuildContext context) {
      final isEditing = widget.editingIngredient != null;

      return SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEditing ? 'Edit Ingredient' : 'Add Ingredient',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Name field (autocomplete)
            CustomDropdownSearch<String>(
              label: 'Ingredient name',
              onFind: (String? filter, int page, int limit) async {
                // call usecase and map to names
                final List<IngredientModel> ingredients =
                    await _ingredientsUsecase(filter ?? '', page, limit);
                return ingredients.map((e) => e.name).toList();
              },
              type: DropdownType.menu,
              // selectedItem must be null if empty
              selectedItem: _nameController.text.isEmpty ? null : _nameController.text,
              showSearchBox: true,
              searchHint: 'Search ingredient...',
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _nameController.text = value;
                  });
                }
              },
              // keep default itemAsString behavior (string already)
            ),
            const SizedBox(height: 16),

            // Quantity + Unit row
            Row(
              children: [
                SizedBox(
                  width: 150,
                  child: TextFormField(
                    controller: _quantityController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: '1/2',
                      labelText: "Quantity",
                      border: const OutlineInputBorder(),
                      suffixIcon: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            child: const Icon(Icons.arrow_drop_up),
                            onTap: _increaseQuantity,
                          ),
                          InkWell(
                            child: const Icon(Icons.arrow_drop_down),
                            onTap: _decreaseQuantity,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Buttons
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
                      widget.onSaveIngredient(
                        RecipeIngredientModel(
                          ingredient: new IngredientModel(name: _nameController.text),
                          quantity: _parseQuantity(
                            _quantityController.text.trim(),
                          ),
                          unit: _unitController.text.trim().isEmpty
                              ? null
                              : _unitController.text.trim(),
                        ),
                        index: widget.editingIndex,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: Text(isEditing ? 'Save' : 'Add'),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
