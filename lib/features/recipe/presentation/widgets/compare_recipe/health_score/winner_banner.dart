import 'package:flutter/material.dart';

class WinnerBanner extends StatelessWidget {
  final double scoreA;
  final double scoreB;
  const WinnerBanner({super.key, required this.scoreA, required this.scoreB});

  @override
  Widget build(BuildContext context) {
    if (scoreA == scoreB) {
      return _buildBanner(
        '🤝 Hai món tương đương nhau về dinh dưỡng!',
        const Color(0xFF607D8B),
      );
    }
    final winner = scoreA > scoreB ? 'Recipe A' : 'Recipe B';
    final color = scoreA > scoreB
        ? const Color(0xFFE8534A)
        : const Color(0xFF2C9E6E);

    return _buildBanner('🏆 $winner tốt hơn cho sức khoẻ!', color);
  }

  Widget _buildBanner(String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
