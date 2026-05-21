import 'package:flutter/material.dart';

class NutritionRecommendationBanner extends StatelessWidget {
  final String summary;
  final String recommendation;
  const NutritionRecommendationBanner({
    super.key,
    required this.summary,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3EE), Color(0xFFFFF8F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD5C2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📌', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  summary,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB84A00),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Recommendation row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  recommendation,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB84A00),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
