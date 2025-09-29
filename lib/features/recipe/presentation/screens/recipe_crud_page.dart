import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/file_upload.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/recipe/data/models/category_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_Ingredient_model.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_cubit.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_state.dart';
import 'package:flutter/material.dart';
import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:eefood/features/recipe/data/models/ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../widgets/basic_info_section.dart';
import '../widgets/ingredients_section.dart';
import '../widgets/instructions_section.dart';

class RecipeCreatePage extends StatefulWidget {
  final RecipeModel? initialRecipe;
  final bool isCreate;

  const RecipeCreatePage({Key? key, this.initialRecipe, required this.isCreate})
    : super(key: key);

  @override
  _RecipeCreatePageState createState() => _RecipeCreatePageState();
}

class _RecipeCreatePageState extends State<RecipeCreatePage> {
  final _formKey = GlobalKey<FormState>();
  late RecipeModel _recipe;
  late List<RecipeIngredientModel> _ingredients;
  late List<RecipeStepModel> _instructions;
  late List<CategoryModel> _categories;
  final _fileUploader = getIt<FileUploader>();
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _recipe = widget.initialRecipe ?? RecipeModel(title: '');
    print(_recipe.id);
    _ingredients = widget.initialRecipe?.ingredients ?? [];
    _instructions = widget.initialRecipe?.steps ?? [];
  }

  void _saveRecipe(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<RecipeCrudCubit>();
       _formKey.currentState!.save();
      if (widget.isCreate) {
        cubit.saveRecipe();
        showCustomSnackBar(context, "Recipe saved successfully");
      } else {
        cubit.updateExistingRecipe(_recipe.id!);
      }
    }
  }

  void _deleteRecipe(BuildContext context) {
    final cubit = context.read<RecipeCrudCubit>();
    cubit.deleteRecipe();
    _removeDropdown();
    showCustomSnackBar(context, "Recipe deleted successfully");
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
                  onTap: () => _deleteRecipe(context),
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
    return BlocProvider(
      create: (_) => getIt<RecipeCrudCubit>(param1: _recipe),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocConsumer<RecipeCrudCubit, RecipeCrudState>(
            listener: (context, state) {
              print('State change: loading=${state.isLoading}, message=${state.message}');
              if (state.message != null) {
                showCustomSnackBar(context, state.message!);
                Navigator.pop(context, true);
              }
            },
            builder: (context, state) {
              return Column(
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
                        if (state.isLoading)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 30),
                            child: SpinKitCircle(
                              color: Colors.orange,
                              size: 50.0,
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.save),
                          onPressed: () {
                            _saveRecipe(context);
                          },
                        ),
                      ],
                    ),
                  ),

                  // Nội dung chính
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BasicInfoSection(),
                            SizedBox(height: 24),
                            IngredientsSection(),
                            SizedBox(height: 24),
                            InstructionsSection(),
                            SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
