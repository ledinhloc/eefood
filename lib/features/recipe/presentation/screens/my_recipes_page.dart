import 'package:eefood/features/recipe/presentation/provider/recipe_refresh_cubit.dart';
import 'package:eefood/features/recipe/presentation/widgets/recipe_tab.dart';
import 'package:flutter/material.dart';
import 'package:eefood/app_routes.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/recipe/domain/usecases/recipe_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyRecipesPage extends StatelessWidget {
  MyRecipesPage({super.key});
  final GetMyRecipe _getMyRecipe = getIt<GetMyRecipe>();
  final RecipeRefreshCubit _refreshCubit = getIt<RecipeRefreshCubit>();

  @override
  Widget build(BuildContext context) {
    final tabTitles = ["Draft", "Published"];

    return BlocProvider.value(
      value: _refreshCubit,
      child: DefaultTabController(
        length: tabTitles.length,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text("My Recipes"),
            actions: [
              IconButton(icon: const Icon(Icons.search), onPressed: () {}),
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
            bottom: TabBar(
              indicatorColor: Colors.red,
              labelColor: Colors.red,
              unselectedLabelColor: Colors.grey,
              tabs: tabTitles.map((t) => Tab(text: t)).toList(),
            ),
          ),
          body: TabBarView(
            children: [
              RecipeTab(
                getMyRecipe: _getMyRecipe,
                status: "DRAFT",
                refreshCubit: _refreshCubit,
              ),
              RecipeTab(
                getMyRecipe: _getMyRecipe,
                status: "PUBLISHED",
                refreshCubit: _refreshCubit,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: "create_recipe",
            shape: const CircleBorder(),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.recipeCrudPage,
                arguments: {"isCreate": true, "initialRecipe": null},
              );
            },
            backgroundColor: Colors.red,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
