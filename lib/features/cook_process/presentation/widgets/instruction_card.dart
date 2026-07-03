import 'package:flutter/material.dart';

class InstructionCard extends StatelessWidget {
  final String instruction;
  const InstructionCard({super.key, required this.instruction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
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
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            instruction,
            style:  TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 16,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
