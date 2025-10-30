import 'package:eefood/app_routes.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_cubit.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_refresh_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../provider/post_cubit.dart';

class RecipeGridCard extends StatefulWidget {
  final RecipeModel recipe;
  final int index;
  final VoidCallback? onRefresh;
  final int crossAxisCount;

  const RecipeGridCard({
    super.key,
    required this.recipe,
    required this.index,
    this.onRefresh,
    this.crossAxisCount = 2,
  });

  @override
  State<RecipeGridCard> createState() => _RecipeGridCardState();
}

class _RecipeGridCardState extends State<RecipeGridCard> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  late RecipeCrudCubit cubit;
  final RecipeRefreshCubit _refreshCubit = getIt<RecipeRefreshCubit>();

  @override
  void initState() {
    super.initState();
    cubit = getIt<RecipeCrudCubit>();
  }

  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _removeDropdown();
    }
  }
  Future<void> _publishRecipe() async {
    _removeDropdown();
    final recipe = widget.recipe;

    if (recipe.id == null) {
      showCustomSnackBar(context, "Công thức không hợp lệ");
      return;
    }

    final TextEditingController contentController = TextEditingController();
    final PostCubit postCubit = getIt<PostCubit>(); // ✅ Lấy PostCubit từ getIt

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Đăng công thức",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: contentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Nội dung bài đăng",
                  hintText: "Hãy chia sẻ đôi điều về công thức này...",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Hủy"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context); // đóng bottom sheet

                      final content = contentController.text.trim();

                      // ✅ Gọi cubit lấy từ getIt, không phụ thuộc context
                      await postCubit.createPost(
                        context,
                        recipe.id!,
                        content.isEmpty ? "" : content,
                      );

                      widget.onRefresh?.call();
                      _refreshCubit.refresh();
                    },
                    child: const Text("Đăng bài"),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _removeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _deleteRecipe() async {
    _removeDropdown();
    if (widget.recipe.id != null) {
      await cubit.deleteRecipe(widget.recipe.id!);
      _refreshCubit.refresh();
      widget.onRefresh?.call();
    } else {
      showCustomSnackBar(context, "Invalid recipe ID");
    }
  }

  OverlayEntry _createOverlayEntry() {
    final columnIndex = widget.index % widget.crossAxisCount;
    final isLeftColumn = columnIndex == 0;
    final isRightColumn = columnIndex == widget.crossAxisCount - 1;

    double offsetX;
    if (isLeftColumn) {
      offsetX = 0;
    } else if (isRightColumn) {
      offsetX = -140;
    } else {
      offsetX = -70;
    }

    return OverlayEntry(
      builder: (context) => Positioned(
        width: 140,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: Offset(offsetX, 40),
          showWhenUnlinked: false,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMenuTile(
                  icon: Icons.delete,
                  title: "Xóa công thức",
                  color: Colors.red,
                  onTap: _deleteRecipe,
                ),
                _buildMenuTile(
                  icon: Icons.publish,
                  title: "Đăng công thức",
                  color: Colors.blue,
                  onTap: _publishRecipe
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
      leading: Icon(icon, color: color, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final String title = recipe.title ?? 'Untitled';

    ImageProvider? imageProvider;
    if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(recipe.imageUrl!);
    }

    return GestureDetector(
      onTap: () async {
        if (recipe.id == null) {
          showCustomSnackBar(context, "Cannot edit recipe: Invalid recipe ID");
          return;
        }
        final result = await Navigator.pushNamed(
          context,
          AppRoutes.recipeCrudPage,
          arguments: {'initialRecipe': recipe, 'isCreate': false},
        );
        if (result == true) {
          widget.onRefresh?.call();
          _refreshCubit.refresh();
        }
      },
      child: Card(
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // --- Image only ---
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                image: imageProvider != null
                    ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                    : null,
              ),
            ),

            // --- Icon More ---
            Positioned(
              top: 8,
              right: 8,
              child: CompositedTransformTarget(
                link: _layerLink,
                child: GestureDetector(
                  onTap: _toggleDropdown,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.6),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.more_vert_sharp,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // --- Title and Info chips ---
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black,
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoSection(recipe),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(RecipeModel recipe) {
    final chips = <Widget>[];

    if (recipe.cookTime != null || recipe.prepTime != null) {
      chips.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (recipe.cookTime != null)
              _infoChip(Icons.timer, "${recipe.cookTime}m"),
            if (recipe.cookTime != null && recipe.prepTime != null)
              const SizedBox(width: 4),
            if (recipe.prepTime != null)
              _infoChip(Icons.kitchen, "${recipe.prepTime}m"),
          ],
        ),
      );
    }

    if (recipe.difficulty != null) {
      if (chips.isNotEmpty) chips.add(const SizedBox(height: 4));
      chips.add(_infoChip(Icons.bar_chart, recipe.difficulty!.name));
    }

    if (recipe.region != null) {
      if (chips.isNotEmpty) chips.add(const SizedBox(height: 4));
      chips.add(
        _infoChip(Icons.location_on_outlined, recipe.region.toString()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: chips,
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _removeDropdown();
    super.dispose();
  }
}
