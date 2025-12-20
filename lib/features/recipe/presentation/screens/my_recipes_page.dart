import 'package:eefood/app_routes.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/recipe/domain/usecases/recipe_usecases.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_list_cubit.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_refresh_cubit.dart';
import 'package:eefood/features/recipe/presentation/widgets/recipe_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/custom_bottom_sheet.dart';
import '../provider/post_cubit.dart';
import '../provider/post_state.dart';
import '../widgets/published/published_list.dart';

class MyRecipesPage extends StatelessWidget {
  MyRecipesPage({super.key});

  final RecipeListCubit _recipeListCubit = getIt<RecipeListCubit>();
  final RecipeRefreshCubit _refreshCubit = getIt<RecipeRefreshCubit>();
  final PostCubit _postCubit = getIt<PostCubit>();

  @override
  Widget build(BuildContext context) {
    final tabTitles = ["Draft", "Published"];

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _recipeListCubit),
        BlocProvider.value(value: _refreshCubit),
        BlocProvider.value(value: _postCubit),
      ],
      child: DefaultTabController(
        length: tabTitles.length,
        child: Scaffold(
          //  Gradient AppBar
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(120),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.orange.shade400,
                    Colors.deepOrange.shade500,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Header Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          // Title với icon
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.menu_book,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Công thức của tôi",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Action buttons
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    // TabBar
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorPadding: const EdgeInsets.all(4),
                        labelColor: Colors.orange.shade700,
                        unselectedLabelColor: Colors.white,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.edit_note, size: 18),
                                SizedBox(width: 6),
                                Text("Nháp"),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.check_circle_outline, size: 18),
                                SizedBox(width: 6),
                                Text("Đã đăng"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),

          body: TabBarView(
            children: [
              // Tab 1: Draft
              RecipeTab(
                recipeListCubit: _recipeListCubit,
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
                    return const Center(
                      child: Text("Chưa có công thức đã đăng"),
                    );
                  }
                },
              ),
            ],
          ),

          // Gradient FloatingActionButton
          floatingActionButton: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.shade400,
                  Colors.deepOrange.shade500,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FloatingActionButton(
              heroTag: "create_recipe",
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(Icons.add, color: Colors.white, size: 32),
              onPressed: () {
                showCustomBottomSheet(context, [
                  BottomSheetOption(
                    icon: Icon(Icons.create, color: Colors.orange.shade700),
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
                    icon: Icon(Icons.link, color: Colors.orange.shade700),
                    title: "Nhập từ URL",
                    onTap: () {
                      _importRecipeFromUrl(context);
                    },
                  ),
                ]);
              },
            ),
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
                        final result = await getIt<CreateRecipeFromUrl>().call(
                          url,
                        );

                        setState(() => isLoading = false);

                        if (result.isSuccess && result.data != null) {
                          Navigator.pop(context); // đóng dialog
                          Navigator.pushNamed(
                            context,
                            AppRoutes.recipeCrudPage,
                            arguments: {
                              "isCreate": false,
                              "initialRecipe": result.data,
                            },
                          );
                        } else {
                          setState(() => isLoading = false);
                          showCustomSnackBar(
                            context,
                            'Nhập công thức thất bại',
                            isError: true,
                          );
                        }
                      } catch (e) {
                        setState(() => isLoading = false);
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
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
