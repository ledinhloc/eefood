import 'dart:async';

import 'package:eefood/app_routes.dart';
import 'package:eefood/features/post/data/models/nullable.dart';
import 'package:eefood/features/post/presentation/provider/post_list_cubit.dart';
import 'package:eefood/features/recipe/presentation/widgets/compare_recipe/item_list_compare/compare_post_item.dart';
import 'package:eefood/features/recipe/presentation/widgets/compare_recipe/item_list_compare/skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CompareSelectorDrawer extends StatefulWidget {
  final int currentRecipeId;
  final String currentRecipeTitle;
  const CompareSelectorDrawer({
    super.key,
    required this.currentRecipeId,
    required this.currentRecipeTitle,
  });

  @override
  State<CompareSelectorDrawer> createState() => _CompareSelectorDrawerState();
}

class _CompareSelectorDrawerState extends State<CompareSelectorDrawer>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _itemAnimController;
  late final TextEditingController _searchController;
  Timer? _debounce;

  int? _selectedRecipeId;
  String? _selectedTitle;
  String? _selectedImageUrl;

  @override
  void initState() {
    super.initState();
    _itemAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _scrollController.addListener(_onScroll);

    final currentState = context.read<PostListCubit>().state;
    _searchController = TextEditingController(text: currentState.keyword ?? '');
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    _itemAnimController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final cubit = context.read<PostListCubit>();
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      cubit.fetchPosts(loadMore: true);
    }
  }

  void _onSelectRecipe(int recipeId, String title, String? imageUrl) {
    setState(() {
      _selectedRecipeId = recipeId;
      _selectedTitle = title;
      _selectedImageUrl = imageUrl;
    });
  }

  void _onConfirmCompare(BuildContext context) {
    if (_selectedRecipeId == null) return;
    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      AppRoutes.recipeComparePage,
      arguments: {
        'recipeIdA': widget.currentRecipeId,
        'recipeIdB': _selectedRecipeId,
      },
    );
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context.read<PostListCubit>().setFilters(
        keyword: value.trim().isEmpty ? Nullable(null) : value.trim(),
      );
    });
  }

  void _onSelectDifficulty(String? value) {
    context.read<PostListCubit>().setFilters(
      difficulty: value == null ? Nullable(null) : value,
    );
  }

  void _onSelectCookTime(int? value) {
    context.read<PostListCubit>().setFilters(
      maxCookTime: value == null ? Nullable(null) : value,
    );
  }

  String _difficultyLabel(String difficulty) {
    switch (difficulty) {
      case 'EASY':
        return 'Dễ';
      case 'MEDIUM':
        return 'Trung bình';
      case 'HARD':
        return 'Khó';
      default:
        return difficulty;
    }
  }

  String _cookTimeLabel(int minutes) {
    if (minutes <= 15) return '< 15 phút';
    if (minutes <= 30) return '< 30 phút';
    if (minutes <= 60) return '< 1 giờ';
    return '> 1 giờ';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth * 0.85;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: drawerWidth,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF8F6F2),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            bottomLeft: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x28000000),
              blurRadius: 32,
              offset: Offset(-8, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(context),
            if (_selectedRecipeId != null) _buildSelectedBanner(),
            Expanded(child: _buildPostList()),
            _buildConfirmButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 16,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.compare_arrows_rounded,
                  color: Color(0xFFFF8C00),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Chọn để so sánh',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EDEA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Color(0xFF666666),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Current recipe badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE8534A), Color(0xFFFF6B5E)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.restaurant_rounded,
                  color: Colors.white,
                  size: 13,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Đang xem: ',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Flexible(
                  child: Text(
                    widget.currentRecipeTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildSearchBar(),
          const SizedBox(height: 10),
          BlocBuilder<PostListCubit, PostListState>(
            builder: (context, state) => _buildFilterRow(state),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F1ED),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: 'Tìm công thức để so sánh...',
          hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: Colors.grey.shade500,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Colors.grey.shade500,
                  ),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildFilterRow(PostListState state) {
    final hasFilters = state.hasFilters();

    return SizedBox(
      height: 34,
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildFilterDropdown<String>(
                  label: state.difficulty != null
                      ? _difficultyLabel(state.difficulty!)
                      : 'Độ khó',
                  isActive: state.difficulty != null,
                  icon: Icons.bolt_rounded,
                  items: const [
                    PopupMenuItem(value: 'EASY', child: Text('Dễ')),
                    PopupMenuItem(value: 'MEDIUM', child: Text('Trung bình')),
                    PopupMenuItem(value: 'HARD', child: Text('Khó')),
                  ],
                  onSelected: _onSelectDifficulty,
                  onClear: () => _onSelectDifficulty(null),
                ),
                const SizedBox(width: 8),
                _buildFilterDropdown<int>(
                  label: state.maxCookTime != null
                      ? _cookTimeLabel(state.maxCookTime!)
                      : 'Thời gian',
                  isActive: state.maxCookTime != null,
                  icon: Icons.timer_outlined,
                  items: const [
                    PopupMenuItem(value: 15, child: Text('Dưới 15 phút')),
                    PopupMenuItem(value: 30, child: Text('Dưới 30 phút')),
                    PopupMenuItem(value: 60, child: Text('Dưới 1 giờ')),
                  ],
                  onSelected: _onSelectCookTime,
                  onClear: () => _onSelectCookTime(null),
                ),
              ],
            ),
          ),
          if (hasFilters)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                context.read<PostListCubit>().resetFilters();
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  'Xóa lọc',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown<T>({
    required String label,
    required bool isActive,
    required IconData icon,
    required List<PopupMenuEntry<T>> items,
    required ValueChanged<T?> onSelected,
    required VoidCallback onClear,
  }) {
    return PopupMenuButton<T>(
      onSelected: onSelected,
      itemBuilder: (_) => items,
      offset: const Offset(0, 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFF3E0) : const Color(0xFFF3F1ED),
          borderRadius: BorderRadius.circular(10),
          border: isActive
              ? Border.all(color: const Color(0xFFFF8C00), width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? const Color(0xFFFF8C00) : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? const Color(0xFFFF8C00)
                    : Colors.grey.shade700,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: const Icon(
                  Icons.close_rounded,
                  size: 12,
                  color: Color(0xFFFF8C00),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedBanner() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C9E6E).withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2C9E6E).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _selectedImageUrl != null
                ? Image.network(
                    _selectedImageUrl!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderThumb(),
                  )
                : _placeholderThumb(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đã chọn để so sánh',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF2C9E6E),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _selectedTitle ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              _selectedRecipeId = null;
              _selectedTitle = null;
              _selectedImageUrl = null;
            }),
            child: const Icon(
              Icons.cancel_rounded,
              color: Color(0xFF2C9E6E),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostList() {
    return BlocBuilder<PostListCubit, PostListState>(
      builder: (context, state) {
        if (state.isLoading && state.posts.isEmpty) {
          return _buildSkeletonList();
        }

        if (state.posts.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          color: const Color(0xFFE8534A),
          backgroundColor: Colors.white,
          onRefresh: () =>
              context.read<PostListCubit>().fetchPosts(loadMore: false),
          child: ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            itemCount: state.posts.length + (state.isLoading ? 1 : 0),
            itemBuilder: (ctx, index) {
              if (index >= state.posts.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFFE8534A),
                      ),
                    ),
                  ),
                );
              }

              final post = state.posts[index];
              final isSelected = _selectedRecipeId == post.recipeId;
              final isCurrent = post.recipeId == widget.currentRecipeId;

              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(
                  milliseconds: 300 + (index * 40).clamp(0, 400),
                ),
                curve: Curves.easeOutCubic,
                builder: (_, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                ),
                child: ComparePostItem(
                  post: post,
                  isSelected: isSelected,
                  isCurrent: isCurrent,
                  onSelect: isCurrent
                      ? null
                      : () => _onSelectRecipe(
                          post.recipeId,
                          post.title,
                          post.imageUrl,
                        ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    final hasSelection = _selectedRecipeId != null;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 8,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: hasSelection ? 1.0 : 0.4,
        child: GestureDetector(
          onTap: hasSelection ? () => _onConfirmCompare(context) : null,
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: hasSelection
                  ? const LinearGradient(
                      colors: [Color(0xFF1A1A1A), Color(0xFF333333)],
                    )
                  : LinearGradient(
                      colors: [Colors.grey.shade300, Colors.grey.shade400],
                    ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: hasSelection
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.compare_arrows_rounded,
                  color: hasSelection ? Colors.white : Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  hasSelection ? 'Bắt đầu so sánh' : 'Chọn một công thức',
                  style: TextStyle(
                    color: hasSelection ? Colors.white : Colors.grey.shade600,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (_, index) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SkeletonItem(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Không có công thức nào',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _placeholderThumb() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.restaurant_rounded, color: Colors.grey, size: 20),
    );
  }
}
