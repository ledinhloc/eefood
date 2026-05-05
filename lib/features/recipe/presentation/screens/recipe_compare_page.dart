import 'package:eefood/features/recipe/presentation/provider/recipe_compare_cubit.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_compare_state.dart';
import 'package:eefood/features/recipe/presentation/widgets/compare_recipe/compare_content.dart';
import 'package:eefood/features/recipe/presentation/widgets/compare_recipe/status_view/error_view.dart';
import 'package:eefood/features/recipe/presentation/widgets/compare_recipe/status_view/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecipeComparePage extends StatefulWidget {
  final int recipeIdA;
  final int recipeIdB;
  const RecipeComparePage({
    super.key,
    required this.recipeIdA,
    required this.recipeIdB,
  });

  @override
  State<RecipeComparePage> createState() => _RecipeComparePageState();
}

class _RecipeComparePageState extends State<RecipeComparePage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
  late Animation<double> _headerFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: Curves.easeOutCubic,
          ),
        );

    context.read<RecipeCompareCubit>().compareRecipes(
      widget.recipeIdA,
      widget.recipeIdB,
    );
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _contentController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocConsumer<RecipeCompareCubit, RecipeCompareState>(
        listener: (context, state) {
          if (state is RecipeCompareLoaded) {
            _startAnimations();
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context, state),
              if (state is RecipeCompareLoading)
                const SliverFillRemaining(child: LoadingView())
              else if (state is RecipeCompareError)
                SliverFillRemaining(child: ErrorView(message: state.message))
              else if (state is RecipeCompareLoaded)
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _headerFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: CompareContent(data: state.data),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, RecipeCompareState state) {
    return SliverAppBar(
      expandedHeight: 70,
      floating: true,
      pinned: true,
      backgroundColor: const Color(0xFFF6F4F1),
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
      ),
      title: const Text(
        'So Sánh Công Thức',
        style: TextStyle(
          fontFamily: 'Merriweather',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1A1A),
          letterSpacing: -0.3,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.share_rounded,
                size: 18,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
