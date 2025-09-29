import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_cubit.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_refresh_cubit.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_state.dart';
import 'package:flutter/material.dart';
import 'package:eefood/features/recipe/data/models/recipe_model.dart';
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
  final RecipeRefreshCubit _refreshCubit = getIt<RecipeRefreshCubit>();

  @override
  void initState() {
    super.initState();
    _recipe = widget.initialRecipe ?? RecipeModel(title: '');
    print(_recipe.id);
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

  @override
  void dispose() {
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
              if (state.message != null) {
                showCustomSnackBar(context, state.message!);
                // Gọi refresh trước khi pop
                _refreshCubit.refresh();
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
