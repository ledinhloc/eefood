import 'package:flutter/material.dart';
import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:eefood/features/recipe/data/models/ingredient_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();

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
      // Here you would typically save _recipe, _ingredients, and _instructions to backend or storage
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe saved successfully')),
      );
    }
  }

  Future<void> _selectImage(File? file) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _recipe.imageUrl = pickedFile.path;
      });
    }
  }

  Future<void> _selectVideo(File? file) async {
    final XFile? pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _recipe.videoUrl = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Recipe'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _saveRecipe,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BasicInfoSection(
                recipe: _recipe,
                onRecipeUpdated: () => setState(() {}),
                onImageSelected: _selectImage,
                onVideoSelected: _selectVideo,
              ),
              const SizedBox(height: 24),
              IngredientsSection(
                ingredients: _ingredients,
                onIngredientsUpdated: () => setState(() {}),
              ),
              const SizedBox(height: 24),
              InstructionsSection(
                instructions: _instructions,
                onInstructionsUpdated: () => setState(() {}),
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _saveRecipe,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                  ),
                  child: const Text('Save Recipe',
                      style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}