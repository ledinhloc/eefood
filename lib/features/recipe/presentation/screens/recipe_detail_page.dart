import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/recipe/presentation/provider/shopping_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_bottom_sheet.dart';
import '../../domain/repositories/shopping_repository.dart';
import '../provider/recipe_detail_cubit.dart';
import '../widgets/instructions_tab.dart';
import '../widgets/steps_tab.dart';
class RecipeDetailPage extends StatelessWidget {
  final int recipeId;
  const RecipeDetailPage({super.key, required this.recipeId});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RecipeDetailCubit()..loadRecipe(recipeId),
      child: BlocBuilder<RecipeDetailCubit, RecipeDetailState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.error != null || state.recipe == null) {
            return Scaffold(
              body: Center(child: Text(state.error ?? 'Không có dữ liệu')),
            );
          }

          final recipe = state.recipe!;
          final totalTime =
              (recipe.prepTime ?? 0) + (recipe.cookTime ?? 0);

          return Scaffold(
            body: DefaultTabController(
              length: 2,
              child: NestedScrollView(
                headerSliverBuilder: (context, _) => [
                  SliverAppBar(
                    expandedHeight: 300,
                    pinned: true,
                    backgroundColor: Colors.white,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () {
                          _showRecipeOption(context, recipe.id!);
                        },
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            recipe.imageUrl ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black54,
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.black26
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Source + title
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              recipe.title,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Info summary
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _infoBlock("${recipe.ingredients?.length ?? 0}",
                              "Ingredients"),
                          _infoBlock("${totalTime}m", "Total Time"),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Text(recipe.description ?? '',
                          style: const TextStyle(fontSize: 15)),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 20),
                          const SizedBox(width: 4),
                          Text("Prep: ${recipe.prepTime ?? 0} min"),
                          const SizedBox(width: 10),
                          Text("Cook: ${recipe.cookTime ?? 0} min"),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(thickness: 1.2),
                      const SizedBox(height: 12),

                      const TabBar(
                        labelColor: Colors.orange,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.orange,
                        tabs: [
                          Tab(text: "Ingredients"),
                          Tab(text: "Instructions"),
                        ],
                      ),

                      SizedBox(
                        height: 600,
                        child: TabBarView(
                          children: [
                            InstructionsTab(recipe: recipe),
                            StepsTab(recipe: recipe),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 4),
          Text(text),
        ],
      ),
    );
  }

  Widget _infoBlock(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.orange)),
        Text(label, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }

  void _showRecipeOption(BuildContext context, int recipeId, {bool isAuthor = false}) {
    final opts = <BottomSheetOption>[
      BottomSheetOption(
        icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.orange),
        title: 'Thêm vào danh sách mua sắm',
        onTap: () => getIt<ShoppingCubit>().addRecipe(recipeId),
      ),
      BottomSheetOption(
        icon: const Icon(Icons.bookmark_border),
        title: 'Lưu công thức',
        onTap: () => {},
      ),
      BottomSheetOption(
        icon: const Icon(Icons.share_outlined),
        title: 'Chia sẻ',
        onTap: () => {},
      ),
      BottomSheetOption(
        icon: const Icon(Icons.search),
        title: 'Tìm món tương tự',
        onTap: () {},
      ),
      BottomSheetOption(
        icon: const Icon(Icons.report_gmailerrorred),
        title: 'Báo cáo',
        onTap: () {},
      ),
    ];
    if (isAuthor) {
      opts.addAll([
        BottomSheetOption(icon: const Icon(Icons.edit), title: 'Chỉnh sửa', onTap: () {}),
        BottomSheetOption(icon: const Icon(Icons.delete_forever), title: 'Xóa', onTap: () {},)
      ]);
    }
    showCustomBottomSheet(context, opts);
  }

}
