import 'package:flutter/material.dart';

class StepChip extends StatelessWidget {
  final int stepNumber;
  const StepChip({super.key, required this.stepNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFFB347)],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        'Bước $stepNumber',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }
}
