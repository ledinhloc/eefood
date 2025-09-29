import 'package:eefood/app_routes.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_cubit.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_refresh_cubit.dart';
import 'package:flutter/material.dart';

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
                  title: "Delete",
                  color: Colors.red,
                  onTap: _deleteRecipe,
                ),
                _buildMenuTile(
                  icon: Icons.publish,
                  title: "Publish",
                  color: Colors.blue,
                  onTap: () {
                    _removeDropdown();
                    widget.onRefresh?.call();
                  },
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
