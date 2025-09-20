import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/file_upload.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_cubit.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_state.dart';
import 'package:flutter/material.dart';
import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:eefood/features/recipe/data/models/ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/basic_info_section.dart';
import '../widgets/ingredients_section.dart';
import '../widgets/instructions_section.dart';

class RecipeCreatePage extends StatefulWidget {
  final RecipeModel? initialRecipe;

  const RecipeCreatePage({Key? key, this.initialRecipe}) : super(key: key);

  @override
  _RecipeCreatePageState createState() => _RecipeCreatePageState();
}

class _RecipeCreatePageState extends State<RecipeCreatePage> {
  final _formKey = GlobalKey<FormState>();
  late RecipeModel _recipe;
  late List<IngredientModel> _ingredients;
  late List<RecipeStepModel> _instructions;
  final _fileUploader = getIt<FileUploader>();

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _recipe = widget.initialRecipe ?? RecipeModel(id: 0, title: '');
    _ingredients = [];
    _instructions = [];
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      context.read<RecipeCrudCubit>().saveRecipe();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe saved successfully')),
      );
    }
  }

  void _deleteRecipe() {
    context.read<RecipeCrudCubit>().deleteRecipe();
    _removeDropdown();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Recipe deleted')));
  }

  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _removeDropdown();
    }
  }

  void _removeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: 160,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: const Offset(-120, 40), // chỉnh vị trí dropdown
          showWhenUnlinked: false,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text("Delete"),
                  onTap: _deleteRecipe,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _removeDropdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar custom
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Create Recipe',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: _saveRecipe,
                  ),
                  CompositedTransformTarget(
                    link: _layerLink,
                    child: IconButton(
                      icon: const Icon(Icons.menu_sharp),
                      onPressed: _toggleDropdown,
                    ),
                  ),
                ],
              ),
            ),

            // Nội dung chính
            Expanded(
              child: Form(
                key: _formKey,
                child: BlocBuilder<RecipeCrudCubit, RecipeCrudState>(
                  builder: (context, state) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BasicInfoSection(),
                          const SizedBox(height: 24),
                          IngredientsSection(),
                          const SizedBox(height: 24),
                          InstructionsSection(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
