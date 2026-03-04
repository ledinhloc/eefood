import 'package:eefood/features/app_settings/collections/app_settings.dart';
import 'package:flutter/material.dart';

class ThemeCard extends StatelessWidget {
  final AppThemeMode mode;
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const ThemeCard({
    super.key,
    required this.mode,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    // Visual mock cho từng theme
    final (bgColor, iconColor) = switch (mode) {
      AppThemeMode.light => (Colors.amber.shade50, Colors.amber.shade700),
      AppThemeMode.dark => (const Color(0xFF1A1A2E), Colors.indigo.shade200),
      AppThemeMode.system => (theme.colorScheme.surfaceVariant, primary),
    };

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        height: 100,
        decoration: BoxDecoration(
          color: isSelected
              ? bgColor
              : theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? iconColor
                  : theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected
                    ? (theme.brightness == Brightness.dark &&
                              mode == AppThemeMode.dark
                          ? Colors.white
                          : theme.colorScheme.onSurface)
                    : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 6),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
