import 'package:eefood/features/recipe/data/models/recipe_compare_model.dart';
import 'package:flutter/material.dart';

class RecipeCardCompare extends StatelessWidget {
  final RecipeCompareModel recipe;
  final String label;
  final Color color;
  const RecipeCardCompare({
    super.key,
    required this.recipe,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildImage(), _buildInfo()],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: recipe.imageUrl != null
              ? Image.network(
                  recipe.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholderImage(),
                )
              : _placeholderImage(),
        ),
        // Label badge
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              'RECIPE $label',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
        // Difficulty badge
        if (recipe.difficulty != null)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _difficultyLabel(recipe.difficulty!),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        // Gradient overlay bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipe.title ?? 'Không có tên',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
              height: 1.3,
            ),
          ),
          if (recipe.region != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on_rounded, size: 10, color: color),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    recipe.region!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          _buildStatRow(
            Icons.schedule_rounded,
            'Tổng',
            _formatTime(recipe.totalTime),
          ),
          const SizedBox(height: 5),
          _buildStatRow(
            Icons.list_alt_rounded,
            'Bước',
            '${recipe.stepCount ?? 0}',
          ),
          const SizedBox(height: 5),
          _buildStatRow(
            Icons.egg_alt_rounded,
            'NL',
            '${recipe.ingredientCount ?? 0}',
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey[500]),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: color.withOpacity(0.08),
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 40,
          color: color.withOpacity(0.4),
        ),
      ),
    );
  }

  String _formatTime(int? minutes) {
    if (minutes == null || minutes == 0) return '-';
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h${m}m';
  }

  String _difficultyLabel(String d) {
    switch (d.toUpperCase()) {
      case 'EASY':
        return 'DỄ';
      case 'MEDIUM':
        return 'TB';
      case 'HARD':
        return 'KHÓ';
      default:
        return d;
    }
  }
}
