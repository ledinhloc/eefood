import 'package:eefood/features/nutrition/data/models/nutrition_display_models.dart';
import 'package:flutter/material.dart';

class NutrientCard extends StatelessWidget {
  final NutrientItem item;
  final Color cardBg;
  final bool isDark;

  const NutrientCard({
    super.key,
    required this.item,
    required this.cardBg,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF111111);
    final subtitleColor = isDark ? Colors.white60 : const Color(0xFF6B6B6B);

    final value = item.value != null ? item.value!.toStringAsFixed(1) : '--';

    return Container(
      constraints: const BoxConstraints(minHeight: 96),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBadge(color: item.color, icon: item.icon),

          const SizedBox(height: 8),

          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              height: 1,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            "${item.unit} · ${item.label}",
            style: TextStyle(
              color: subtitleColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _IconBadge({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

class NutrientChip extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;

  const NutrientChip({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.85),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            "${value.toStringAsFixed(1)}$unit",
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
