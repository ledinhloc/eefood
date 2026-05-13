import 'package:eefood/features/chatbot/data/models/nutrition_macro_item.dart';
import 'package:flutter/material.dart';

class NutritionMarcoGrid extends StatelessWidget {
  final List<NutritionMacroItem> macros;
  const NutritionMarcoGrid({super.key, required this.macros});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Row(
        children: macros
            .map((m) => Expanded(child: _MacroTile(macro: m)))
            .toList(),
      ),
    );
  }
}

class _MacroTile extends StatelessWidget {
  final NutritionMacroItem macro;

  const _MacroTile({required this.macro});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: macro.color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(macro.icon, color: macro.color, size: 18),
          const SizedBox(height: 4),
          Text(
            macro.value != null ? macro.value!.toStringAsFixed(1) : '--',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: macro.color,
            ),
          ),
          Text(
            macro.unit,
            style: TextStyle(
              fontSize: 9,
              color: macro.color.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            macro.label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
