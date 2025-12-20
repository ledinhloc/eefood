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

  IngredientModel? _selectedIngredient;
  bool _isManualInput = false; // Để track xem user đang nhập tay hay không

  @override
  void initState() {
    super.initState();
    if (widget.editingIngredient != null) {
      _nameController.text = widget.editingIngredient!.ingredient!.name;
      _selectedIngredient = widget.editingIngredient!.ingredient;
      if (widget.editingIngredient!.quantity != null) {
        _quantityController.text = widget.editingIngredient!.quantity!.toString();
      }
      if (widget.editingIngredient!.unit != null) {
        _unitController.text = widget.editingIngredient!.unit!;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
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

  void _showAddIngredientDialog(BuildContext context) {
    final TextEditingController newIngredientController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add New Ingredient'),
        content: TextField(
          controller: newIngredientController,
          decoration: InputDecoration(
            labelText: 'Ingredient Name',
            hintText: 'Enter ingredient name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.deepOrangeAccent,
                width: 2,
              ),
            ),
            prefixIcon: const Icon(Icons.restaurant),
          ),
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              setState(() {
                _selectedIngredient = IngredientModel(name: value.trim());
                _nameController.text = value.trim();
                _isManualInput = true;
              });
              Navigator.of(dialogContext).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              newIngredientController.clear();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = newIngredientController.text.trim();
              if (value.isNotEmpty) {
                setState(() {
                  _selectedIngredient = IngredientModel(name: value);
                  _nameController.text = value;
                  _isManualInput = true;
                });
                Navigator.of(dialogContext).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
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

          // Name field with Add button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomDropdownSearch<IngredientModel>(
                  label: 'Ingredient name',
                  onFind: (String? filter, int page, int limit) async {
                    final List<IngredientModel> ingredients =
                    await _ingredientsUsecase(filter ?? '', page, limit);
                    return ingredients;
                  },
                  type: DropdownType.menu,
                  selectedItem: _selectedIngredient,
                  showSearchBox: true,
                  searchHint: 'Search ingredient...',
                  itemAsString: (ingredient) => ingredient.name,
                  onChanged: (value) {
                    setState(() {
                      _selectedIngredient = value;
                      _isManualInput = false;
                      if (value != null) {
                        _nameController.text = value.name;
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Nút Add ingredient mới
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: IconButton(
                  onPressed: () => _showAddIngredientDialog(context),
                  icon: Icon(
                    Icons.add_circle,
                    color: Colors.red.shade600,
                    size: 32,
                  ),
                  tooltip: 'Add new ingredient',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  if (_selectedIngredient == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please select or add an ingredient',
                        ),
                      ),
                    );
                    return;
                  }

                  widget.onSaveIngredient(
                    RecipeIngredientModel(
                      ingredient: _selectedIngredient!,
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