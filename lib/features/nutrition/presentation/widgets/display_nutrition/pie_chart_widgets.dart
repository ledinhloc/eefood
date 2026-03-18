import 'package:eefood/features/nutrition/data/models/nutrition_display_models.dart';
import 'package:flutter/material.dart';

class PieBadge extends StatelessWidget {
  final MacroData macro;

  const PieBadge({super.key, required this.macro});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: macro.color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: macro.color.withOpacity(0.45),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            macro.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          Text(
            '${macro.value.toStringAsFixed(1)}${macro.unit}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class PieTouchTooltip extends StatelessWidget {
  final MacroData macro;
  final Offset position;

  const PieTouchTooltip({
    super.key,
    required this.macro,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: PieBadge(macro: macro),
    );
  }
}

class PieLegendItem extends StatelessWidget {
  final MacroData macro;
  final bool isDark;

  const PieLegendItem({super.key, required this.macro, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark ? Colors.white54 : Colors.black45;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: macro.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  macro.label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${macro.value.toStringAsFixed(1)} ${macro.unit}',
                  style: TextStyle(color: subtitleColor, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
