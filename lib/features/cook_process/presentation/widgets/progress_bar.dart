import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  const ProgressBar({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: current / total,
          backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
          minHeight: 4,
        ),
      ),
    );
  }
}
