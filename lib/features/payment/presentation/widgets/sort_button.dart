import 'package:flutter/material.dart';

class SortButton extends StatelessWidget {
  final String sort;
  final VoidCallback onToggle;
  const SortButton({super.key, required this.sort, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isNewest = sort == 'newest';
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isNewest
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              size: 14,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              isNewest ? 'Mới nhất' : 'Cũ nhất',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
