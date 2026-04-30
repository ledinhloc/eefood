import 'package:flutter/material.dart';

class NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final bool outlined;
  final bool expanded;
  final VoidCallback onTap;
  const NavButton({
    super.key,
    required this.icon,
    required this.label,
    required this.enabled,
    required this.outlined,
    required this.onTap,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? Colors.white : Colors.white.withOpacity(0.2);
    final child = GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: outlined
              ? Colors.white.withOpacity(enabled ? 0.08 : 0.03)
              : (enabled
                    ? const Color(0xFFFF6B35)
                    : Colors.white.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(16),
          border: outlined
              ? Border.all(
                  color: Colors.white.withOpacity(enabled ? 0.2 : 0.08),
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (outlined) Icon(icon, color: color, size: 20),
            if (!outlined) ...[
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: color, size: 20),
            ] else ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return expanded ? SizedBox(width: double.infinity, child: child) : child;
  }
}
