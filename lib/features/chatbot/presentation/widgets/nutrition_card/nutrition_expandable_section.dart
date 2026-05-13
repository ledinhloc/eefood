import 'package:eefood/features/chatbot/data/models/nutrition_macro_item.dart';
import 'package:flutter/material.dart';

class NutritionExpandableSection extends StatefulWidget {
  final List<NutritionMicroItem> microItems;
  final List<dynamic>? ingredientDetails;
  const NutritionExpandableSection({
    super.key,
    required this.microItems,
    required this.ingredientDetails,
  });

  @override
  State<NutritionExpandableSection> createState() =>
      _NutritionExpandableSectionState();
}

class _NutritionExpandableSectionState
    extends State<NutritionExpandableSection> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    final hasIngredients =
        widget.ingredientDetails != null &&
        widget.ingredientDetails!.isNotEmpty;
    final hasContent = widget.microItems.isNotEmpty || hasIngredients;

    if (!hasContent) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text(
                  _expanded ? 'Thu gọn' : 'Xem chi tiết',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFFF6B35),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: Color(0xFFFF6B35),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _expanded
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.microItems.isNotEmpty) ...[
                      _sectionLabel('Vi chất'),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                        child: Row(
                          children: widget.microItems
                              .map((m) => Expanded(child: _MicroTile(micro: m)))
                              .toList(),
                        ),
                      ),
                    ],
                    if (hasIngredients) ...[
                      _sectionLabel('Nguyên liệu'),
                      ...widget.ingredientDetails!
                          .take(5)
                          .map((ing) => _IngredientRow(ingredient: ing)),
                      if (widget.ingredientDetails!.length > 5)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                          child: Text(
                            '+ ${widget.ingredientDetails!.length - 5} nguyên liệu khác',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                    ],
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade500,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _MicroTile extends StatelessWidget {
  final NutritionMicroItem micro;

  const _MicroTile({required this.micro});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: micro.color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            micro.value.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: micro.color,
            ),
          ),
          Text(
            micro.unit,
            style: TextStyle(fontSize: 9, color: micro.color.withOpacity(0.8)),
          ),
          const SizedBox(height: 2),
          Text(
            micro.label,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final dynamic ingredient;

  const _IngredientRow({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    final name = ingredient.ingredientName as String? ?? '';
    final calories = ingredient.calories as double? ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFFF6B35),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${calories.toStringAsFixed(0)} kCal',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
