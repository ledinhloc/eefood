import 'package:eefood/app_routes.dart';
import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:eefood/features/recipe/presentation/widgets/recipe_grid_card.dart';
import 'package:flutter/material.dart';
class MyRecipesPage extends StatelessWidget {
  const MyRecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu demo cho mỗi tab
    final List<List<RecipeModel>> recipeTabs = [
      <RecipeModel>[], // Draft
      <RecipeModel>[], // Published
    ];

    final List<String> tabTitles = [
      "Draft",
      "Published",
    ];

    return DefaultTabController(
      length: tabTitles.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text("My Recipes"),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.red,
            labelColor: Colors.red,
            unselectedLabelColor: Colors.grey,
            tabs: tabTitles.map((title) => Tab(text: title)).toList(),
          ),
        ),
        body: TabBarView(
          children: recipeTabs
              .map((recipes) => RecipeGridCard(recipes: recipes))
              .toList(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.recipeCrudPage);
          },
          backgroundColor: Colors.red,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}