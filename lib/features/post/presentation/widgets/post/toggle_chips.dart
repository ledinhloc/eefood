import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class ToggleChips extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onTap;

  const ToggleChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = opt == selected;

        return FilterChip(
          label: Text(opt),
          selected: isSelected,
          onSelected: (bool newSelected) {
            onTap(isSelected ? null : opt);
          },
          selectedColor: Colors.orange.shade100,
          checkmarkColor: Colors.orange.shade700,
          backgroundColor: Colors.grey.shade50,
          labelStyle: TextStyle(
            color: isSelected ? Colors.orange.shade900 : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected ? Colors.orange.shade400 : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }).toList(),
    );
  }
}
