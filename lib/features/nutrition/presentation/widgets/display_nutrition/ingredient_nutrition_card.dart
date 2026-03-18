import 'package:eefood/features/nutrition/data/models/ingredient_nutrition_detail_model.dart';
import 'package:eefood/features/nutrition/presentation/utils/nutrition_helpers.dart';
import 'package:eefood/features/nutrition/presentation/widgets/display_nutrition/nutrient_card.dart';
import 'package:flutter/material.dart';

class IngredientNutritionCard extends StatefulWidget {
  final IngredientNutritionDetailModel ingredient;
  final int index;
  final bool isDark;

  const IngredientNutritionCard({
    super.key,
    required this.ingredient,
    required this.index,
    required this.isDark,
  });

  @override
  State<IngredientNutritionCard> createState() => _IngredientNutritionCardState();
}

class _IngredientNutritionCardState extends State<IngredientNutritionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark ? Colors.white54 : Colors.black45;
    final dividerColor = isDark
        ? Colors.white12
        : Colors.black.withOpacity(0.06);
    final accent =
        ingredientAccentColors[widget.index % ingredientAccentColors.length];
    final ing = widget.ingredient;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dividerColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(ing, accent, textColor, subtitleColor),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: _buildDetails(ing, dividerColor),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    IngredientNutritionDetailModel ing,
    Color accent,
    Color textColor,
    Color subtitleColor,
  ) {
    return Row(
      children: [
        // Index circle
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${widget.index + 1}',
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Name + quantity
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ing.ingredientName ?? 'Nguyên liệu',
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (ing.quantity != null && ing.unit != null)
                Text(
                  '${ing.quantity!.toStringAsFixed(0)} ${ing.unit}',
                  style: TextStyle(color: subtitleColor, fontSize: 12),
                ),
            ],
          ),
        ),
        // Calories badge
        if (ing.calories != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B00).withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${ing.calories!.toStringAsFixed(0)} kcal',
              style: const TextStyle(
                color: Color(0xFFFF6B00),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        const SizedBox(width: 8),
        // Chevron
        AnimatedRotation(
          turns: _expanded ? 0.5 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Icon(Icons.keyboard_arrow_down_rounded, color: subtitleColor),
        ),
      ],
    );
  }

  Widget _buildDetails(IngredientNutritionDetailModel ing, Color dividerColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        children: [
          Divider(color: dividerColor, height: 1),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (ing.protein != null)
                NutrientChip(
                  label: 'Protein',
                  value: ing.protein!,
                  unit: 'g',
                  color: const Color(0xFF4FC3F7),
                ),
              if (ing.fat != null)
                NutrientChip(
                  label: 'Fat',
                  value: ing.fat!,
                  unit: 'g',
                  color: const Color(0xFFFFB74D),
                ),
              if (ing.carb != null)
                NutrientChip(
                  label: 'Carb',
                  value: ing.carb!,
                  unit: 'g',
                  color: const Color(0xFF81C784),
                ),
              if (ing.fiber != null)
                NutrientChip(
                  label: 'Fiber',
                  value: ing.fiber!,
                  unit: 'g',
                  color: const Color(0xFFBA68C8),
                ),
              if (ing.sugar != null)
                NutrientChip(
                  label: 'Sugar',
                  value: ing.sugar!,
                  unit: 'g',
                  color: const Color(0xFFF06292),
                ),
              if (ing.calcium != null)
                NutrientChip(
                  label: 'Calcium',
                  value: ing.calcium!,
                  unit: 'mg',
                  color: const Color(0xFF4DB6AC),
                ),
              if (ing.sodium != null)
                NutrientChip(
                  label: 'Sodium',
                  value: ing.sodium!,
                  unit: 'mg',
                  color: const Color(0xFFFF8A65),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
