import 'dart:async';
import 'package:eefood/features/recipe/presentation/provider/recipe_list_cubit.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_refresh_cubit.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_state.dart';
import 'package:eefood/features/recipe/presentation/widgets/recipe_grid_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecipeTab extends StatefulWidget {
  final RecipeListCubit recipeListCubit;
  final RecipeRefreshCubit refreshCubit;

  const RecipeTab({
    super.key,
    required this.recipeListCubit,
    required this.refreshCubit,
  });

  @override
  State<RecipeTab> createState() => _RecipeTabState();
}

class _RecipeTabState extends State<RecipeTab>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  late final StreamSubscription _refreshSub;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _refreshSub = widget.refreshCubit.stream.listen((_) {
      if (!mounted) return;
      widget.recipeListCubit.refresh();
    });

    widget.recipeListCubit.fetchDraftRecipes();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!widget.recipeListCubit.state.isLoading &&
          widget.recipeListCubit.state.hasDraftMore) {
        widget.recipeListCubit.fetchDraftRecipes(loadMore: true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<RecipeListCubit, RecipeListState>(
      bloc: widget.recipeListCubit,
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async {
            await widget.recipeListCubit.refresh();
          },
          child: _buildContent(state),
        );
      },
    );
  }

  Widget _buildContent(RecipeListState state) {
    // Loading
    if (state.isLoading && state.draftRecipes.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(
            height: 400,
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    // Error
    if (state.error != null && state.draftRecipes.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 400,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.error}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => widget.recipeListCubit.refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Empty
    if (state.draftRecipes.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 400,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    "Chưa có công thức nháp",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Kéo xuống để làm mới",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Has data
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.65,
      ),
      itemCount: state.draftRecipes.length + (state.hasDraftMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.draftRecipes.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final recipe = state.draftRecipes[index];
        return RecipeGridCard(
          recipe: recipe,
          index: index,
          key: ValueKey(recipe.id),
          onRefresh: () => widget.recipeListCubit.refresh(),
        );
      },
    );
  }
}