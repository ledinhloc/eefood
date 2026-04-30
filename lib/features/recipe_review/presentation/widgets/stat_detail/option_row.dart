import 'package:eefood/features/recipe_review/data/models/option_state_model.dart';
import 'package:flutter/material.dart';

class OptionRow extends StatelessWidget {
  final OptionStateModel option;
  final Color color;
  final bool isHighlighted;
  const OptionRow({
    super.key,
    required this.option,
    required this.color,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (option.percent ?? 0) / 100;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlighted ? color.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted ? color.withOpacity(0.4) : Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.content ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isHighlighted
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 5,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(option.percent ?? 0).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                '${option.count ?? 0} lượt',
                style: const TextStyle(fontSize: 11, color: Colors.black38),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
