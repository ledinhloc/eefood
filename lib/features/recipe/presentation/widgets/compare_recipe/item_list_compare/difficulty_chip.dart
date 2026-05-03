import 'package:flutter/widgets.dart';

class DifficultyChip extends StatelessWidget {
  final String difficulty;
  const DifficultyChip({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (difficulty.toUpperCase()) {
      'EASY' => ('DỄ', const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
      'MEDIUM' => ('TB', const Color(0xFFFFF3E0), const Color(0xFFE65100)),
      'HARD' => ('KHÓ', const Color(0xFFFFEBEE), const Color(0xFFC62828)),
      _ => (difficulty, const Color(0xFFF0EDEA), const Color(0xFF666666)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
