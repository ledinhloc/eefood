import 'package:flutter/material.dart';

class NavigationBarReview extends StatelessWidget {
  final int current;
  final int total;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const NavigationBarReview({
    super.key,
    required this.current,
    required this.total,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavButton(
            label: "Trước",
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: current > 0 ? onPrev : null,
            isLeft: true,
          ),
          Text(
            "${current + 1} / $total",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          _NavButton(
            label: "Tiếp",
            icon: Icons.arrow_forward_ios_rounded,
            onTap: current < total - 1 ? onNext : null,
            isLeft: false,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isLeft;

  const _NavButton({
    required this.label,
    required this.icon,
    this.onTap,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: enabled ? Colors.orange : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: isLeft
              ? [
                  Icon(
                    icon,
                    size: 14,
                    color: enabled ? Colors.white : Colors.black26,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: enabled ? Colors.white : Colors.black26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ]
              : [
                  Text(
                    label,
                    style: TextStyle(
                      color: enabled ? Colors.white : Colors.black26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    icon,
                    size: 14,
                    color: enabled ? Colors.white : Colors.black26,
                  ),
                ],
        ),
      ),
    );
  }
}
