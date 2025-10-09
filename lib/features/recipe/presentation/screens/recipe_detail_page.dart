import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/recipe_repository.dart';
import '../provider/recipe_detail_cubit.dart';

class RecipeDetailPage extends StatelessWidget {
  final int recipeId;

  const RecipeDetailPage({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RecipeDetailCubit()..loadRecipe(recipeId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Chi tiết món ăn')),
        body: BlocBuilder<RecipeDetailCubit, RecipeDetailState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              // return Center(child: Text('Lỗi: ${state.error}'));
              return const Center(child: Text('Không có dữ liệu'));
            }
            final recipe = state.recipe;
            if (recipe == null) {
              return const Center(child: Text('Không có dữ liệu'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thông tin user
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: recipe.avatarUrl != null
                            ? NetworkImage(recipe.avatarUrl!)
                            : null,
                        radius: 20,
                        child: recipe.avatarUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(recipe.username,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          Text(recipe.email,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Ảnh món ăn
                  if (recipe.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(recipe.imageUrl!, fit: BoxFit.cover),
                    ),

                  const SizedBox(height: 12),
                  Text(recipe.title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  if (recipe.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(recipe.description!),
                    ),

                  const SizedBox(height: 16),
                  Text("🧂 Nguyên liệu",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  ...?recipe.ingredients?.map(
                        (ing) => ListTile(
                      title: Text(ing.ingredient?.name ?? ''),
                      subtitle:
                      Text("${ing.quantity ?? ''} ${ing.unit ?? ''}"),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text("👨‍🍳 Các bước thực hiện",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  ...?recipe.steps?.map(
                        (step) => ListTile(
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.orange.shade100,
                        child: Text("${step.stepNumber}",
                            style: const TextStyle(color: Colors.black)),
                      ),
                      title: Text(step.instruction ?? ''),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
