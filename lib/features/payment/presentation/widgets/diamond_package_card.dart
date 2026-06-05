import 'package:eefood/features/payment/presentation/provider/diamond_packages_state.dart';
import 'package:flutter/material.dart';

class DiamondPackageCard extends StatelessWidget {
  final DiamondPackage package;
  final VoidCallback onTap;
  final bool isSelected;

  const DiamondPackageCard({
    super.key,
    required this.package,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    Colors.orange.shade400.withValues(alpha: 0.1),
                    Colors.deepOrange.shade500.withValues(alpha: 0.05),
                  ],
                )
              : LinearGradient(
                  colors: [
                    theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                    theme.scaffoldBackgroundColor,
                  ],
                ),
          border: Border.all(
            color: isSelected
                ? Colors.deepOrange.shade500
                : const Color(0xFF3A3A4E),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.deepOrange.shade500.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              // Top section: Diamond amount
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('💎', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 4),
                      Text(
                        '${package.diamondAmount}',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Bonus diamond badge
                  if (package.bonusDiamond > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF6B6B),
                            const Color(0xFFEE5A52),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+${package.bonusDiamond}',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              // Total diamond
              if (package.bonusDiamond > 0)
                Text(
                  'Tổng: ${package.totalDiamond}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 10,
                  ),
                ),
              const SizedBox(height: 4),
              // Price section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C6AFF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  package.displayPrice,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF7C6AFF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Select button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            Colors.orange.shade400,
                            Colors.deepOrange.shade500,
                          ],
                        )
                      : null,
                  color: isSelected ? null : const Color(0xFF3A3A4E),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  isSelected ? 'Đã chọn' : 'Chọn',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
