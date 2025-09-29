import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:eefood/features/recipe/domain/usecases/recipe_usecases.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_refresh_cubit.dart';
import 'package:eefood/features/recipe/presentation/widgets/recipe_grid_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class RecipeTab extends StatefulWidget {
  final GetMyRecipe getMyRecipe;
  final String status;
  final RecipeRefreshCubit refreshCubit;

  const RecipeTab({
    super.key,
    required this.getMyRecipe,
    required this.status,
    required this.refreshCubit,
  });

  @override
  State<RecipeTab> createState() => _RecipeTabState();
}

class _RecipeTabState extends State<RecipeTab>
    with AutomaticKeepAliveClientMixin {
  // Thêm mixin để keep state alive trong TabBarView
  static const int _pageSize = 5;
  static const int _firstPage = 1; // Hoặc 1 tùy theo API của bạn

  final PagingController<int, RecipeModel> _pagingController = PagingController(
    firstPageKey: _firstPage,
  );

  // Thêm biến để store listener, để remove nếu cần
  void Function(int)? _pageRequestListener;

  @override
  bool get wantKeepAlive => true; // Giữ state alive

  @override
  void initState() {
    super.initState();
    _addPageRequestListener();
  }

  void _addPageRequestListener() {
    // Remove old listener nếu tồn tại (safe guard chống multiple add)
    if (_pageRequestListener != null) {
      _pagingController.removePageRequestListener(_pageRequestListener!);
    }
    _pageRequestListener = (pageKey) {
      _fetchPage(pageKey);
    };
    _pagingController.addPageRequestListener(_pageRequestListener!);

    widget.refreshCubit.stream.listen((_) {
      _pagingController.refresh();
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    print('Fetching page $pageKey, status=${widget.status}');
    try {
      final result = await widget.getMyRecipe(
        null, // title
        null, // description
        null, // region
        null, // difficulty
        null, // categoryId
        pageKey, // page index
        _pageSize,
        'createdAt',
        'DESC',
      );

      if (result.isSuccess) {
        List<RecipeModel>? newItems = result.data;

        if (newItems != null) {
          // Deduplicate: Lọc bỏ items đã tồn tại dựa trên id (giả sử id unique)
          final existingItems = _pagingController.itemList ?? [];
          newItems = newItems.where((newItem) {
            return !existingItems.any((existing) => existing.id == newItem.id);
          }).toList();
        }

        // Kiểm tra nếu không có item mới hoặc số lượng ít hơn pageSize
        // thì đây là trang cuối cùng
        if (newItems == null ||
            newItems.isEmpty ||
            newItems.length < _pageSize) {
          _pagingController.appendLastPage(newItems ?? []);
        } else {
          final nextPageKey =
              pageKey + 1; // Hoặc pageKey + newItems.length tùy API
          _pagingController.appendPage(newItems, nextPageKey);
        }
      } else {
        throw Exception('Fetch failed: ${result.error}');
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    if (_pageRequestListener != null) {
      _pagingController.removePageRequestListener(_pageRequestListener!);
    }
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Gọi cho keepAlive
    return RefreshIndicator(
      // Thêm RefreshIndicator nếu chưa có, để pull-to-refresh
      onRefresh: () async {
        _pagingController.refresh(); // Refresh sẽ clear và fetch lại từ page 1
      },
      child: PagedGridView<int, RecipeModel>(
        pagingController: _pagingController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 0,
          childAspectRatio: 0.65,
        ),
        builderDelegate: PagedChildBuilderDelegate<RecipeModel>(
          itemBuilder: (context, recipe, index) => RecipeGridCard(
            recipe: recipe,
            index: index,
            key: ValueKey(recipe.id),
            onRefresh: () => _pagingController.refresh(),
          ), // Thêm key dựa trên id để avoid rebuild duplicate UI
          firstPageProgressIndicatorBuilder: (_) => const Center(
            child: SpinKitCircle(color: Colors.orange, size: 50.0),
          ),
          newPageProgressIndicatorBuilder: (_) => const Center(
            child: SpinKitCircle(color: Colors.orange, size: 50.0),
          ),
          noItemsFoundIndicatorBuilder: (_) =>
              const Center(child: Text("No recipes found")),
          firstPageErrorIndicatorBuilder: (context) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${_pagingController.error}'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _pagingController.refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          newPageErrorIndicatorBuilder: (context) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Load more error: ${_pagingController.error}'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _pagingController.retryLastFailedRequest(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
