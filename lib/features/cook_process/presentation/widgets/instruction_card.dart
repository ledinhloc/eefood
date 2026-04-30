import 'package:flutter/material.dart';

class InstructionCard extends StatelessWidget {
  final String instruction;
  const InstructionCard({super.key, required this.instruction});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.menu_book_rounded,
                color: Color(0xFFFF6B35),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Hướng dẫn',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            instruction,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
