import 'package:flutter/material.dart';

class NutritionSummaryBubble extends StatelessWidget {
  final String summary;
  const NutritionSummaryBubble({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        summary,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade700,
          height: 1.5,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
