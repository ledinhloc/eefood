import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_refresh_cubit.dart';
import 'package:eefood/features/recipe/presentation/widgets/recipe_tab.dart';
import 'package:flutter/material.dart';
import 'package:eefood/app_routes.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/recipe/domain/usecases/recipe_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/custom_bottom_sheet.dart';
import '../provider/post_cubit.dart';
import '../provider/post_state.dart';
import '../widgets/published/published_list.dart';

class MyRecipesPage extends StatelessWidget {
  MyRecipesPage({super.key});

  final GetMyRecipe _getMyRecipe = getIt<GetMyRecipe>();
  final RecipeRefreshCubit _refreshCubit = getIt<RecipeRefreshCubit>();
  final PostCubit _postCubit = getIt<PostCubit>();

  @override
  Widget build(BuildContext context) {
    final tabTitles = ["Draft", "Published"];

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _refreshCubit),
        BlocProvider.value(value: _postCubit),
      ],
      child: DefaultTabController(
        length: tabTitles.length,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
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
              // Tab 1: Draft
              RecipeTab(
                getMyRecipe: _getMyRecipe,
                status: "DRAFT",
                refreshCubit: _refreshCubit,
              ),

              // Tab 2: Published
              BlocBuilder<PostCubit, PostState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state.posts.isNotEmpty) {
                    return PublishedList(posts: state.posts);
                  } else {
                    return const Center(child: Text("Chưa có công thức đã đăng"));
                  }
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: "create_recipe",
            shape: const CircleBorder(),
            backgroundColor: Colors.red,
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              showCustomBottomSheet(
                context,
                [
                  BottomSheetOption(
                    icon: const Icon(Icons.create, color: Colors.black),
                    title: "Tạo công thức mới",
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.recipeCrudPage,
                        arguments: {"isCreate": true, "initialRecipe": null},
                      );
                    },
                  ),
                  BottomSheetOption(
                    icon: const Icon(Icons.link, color: Colors.black),
                    title: "Nhập từ URL",
                    onTap: () {
                      _importRecipeFromUrl(context);
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _importRecipeFromUrl(BuildContext context) {
    final urlController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false, // không đóng khi click ngoài
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Nhập URL công thức"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: urlController,
                decoration: const InputDecoration(hintText: "https://..."),
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
          actions: [
            if (!isLoading)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Hủy"),
              ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                final url = urlController.text.trim();
                if (url.isEmpty) return;

                setState(() => isLoading = true);

                try {
                  final result =
                  await getIt<CreateRecipeFromUrl>().call(url);

                  setState(() => isLoading = false);

                  if (result.isSuccess && result.data != null) {
                    Navigator.pop(context); // đóng dialog
                    Navigator.pushNamed(
                      context,
                      AppRoutes.recipeCrudPage,
                      arguments: {
                        "isCreate": false,
                        "initialRecipe": result.data
                      },
                    );
                  } else {
                    setState(() => isLoading = false);
                    showCustomSnackBar(context, 'Nhập công thức thất bại', isError: true);
                  }
                } catch (e) {
                  setState(() => isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Lỗi: $e"),
                    ),
                  );
                }
              },
              child: const Text("Nhập"),
            ),
          ],
        ),
      ),
    );
  }
}