import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../provider/recipe_detail_cubit.dart';
import 'package:video_player/video_player.dart';

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
          return Scaffold(
            body: DefaultTabController(
              length: 2,
              child: NestedScrollView(
                headerSliverBuilder: (context, _) => [
                  SliverAppBar(
                    expandedHeight: 320,
                    pinned: true,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.black87),
                        onPressed: () {},
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
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.black45, Colors.transparent],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                body: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nguồn + tiêu đề
                            Center(
                              child: Column(
                                children: [
                                  Text("elavegan.com",
                                      style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text(
                                    recipe.title,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Like + comment
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _iconText(Icons.thumb_up_alt_outlined, "96%"),
                                const SizedBox(width: 16),
                                _iconText(Icons.comment_outlined, "9"),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Info hàng ngang
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _infoBlock("16", "Ingredients"),
                                _infoBlock("1h 5m", "Instructions"),
                                _infoBlock("8.8", "Health Score"),
                              ],
                            ),

                            const SizedBox(height: 20),

                            Text(
                              recipe.description ?? '',
                              style: const TextStyle(
                                  color: Colors.black87, fontSize: 15),
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                const Icon(Icons.schedule, size: 20),
                                const SizedBox(width: 4),
                                Text("Prep: ${recipe.prepTime ?? 0} min",
                                    style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 8),
                                Text("Cook: ${recipe.cookTime ?? 0} min",
                                    style: const TextStyle(fontSize: 14)),
                              ],
                            ),

                            const SizedBox(height: 20),
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
                              height: 500, // Chiều cao nội dung tab
                              child: TabBarView(
                                children: [
                                  _buildIngredients(recipe),
                                  _buildSteps(recipe),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
          Text(text, style: const TextStyle(color: Colors.black87)),
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

  Widget _buildIngredients(recipe) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: recipe.ingredients?.length ?? 0,
      itemBuilder: (context, index) {
        final ing = recipe.ingredients![index];
        return ListTile(
          leading: ing.ingredient?.image != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              ing.ingredient!.image!,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          )
              : const Icon(Icons.fastfood, color: Colors.orange),
          title: Text(ing.ingredient?.name ?? ''),
          subtitle: Text("${ing.quantity ?? ''} ${ing.unit ?? ''}"),
        );
      },
    );
  }

  Widget _buildSteps(recipe) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: recipe.steps?.length ?? 0,
      itemBuilder: (context, index) {
        final step = recipe.steps![index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Bước ${step.stepNumber}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                Text(step.instruction ?? ''),
                if (step.imageUrl != null && step.imageUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(step.imageUrl!),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}