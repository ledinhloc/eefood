import 'package:flutter/material.dart';

class MedalBadge extends StatelessWidget {
  final String emoji;
  final Gradient gradient;
  final double size;
  const MedalBadge({
    super.key,
    required this.emoji,
    required this.gradient,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (gradient as LinearGradient).colors.first.withValues(
              alpha: 0.4,
            ),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: size * 0.5)),
      ),
    );
  }
}
