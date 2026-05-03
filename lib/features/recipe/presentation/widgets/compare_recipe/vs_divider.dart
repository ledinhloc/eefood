import 'package:eefood/features/recipe/data/models/recipe_compare_model.dart';
import 'package:flutter/material.dart';

class VsDivider extends StatelessWidget {
  final RecipeCompareModel recipeA;
  final RecipeCompareModel recipeB;
  const VsDivider({super.key, required this.recipeA, required this.recipeB});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFE8534A).withOpacity(0.0),
                  const Color(0xFFE8534A).withOpacity(0.5),
                ],
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'VS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2C9E6E).withOpacity(0.5),
                  const Color(0xFF2C9E6E).withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
