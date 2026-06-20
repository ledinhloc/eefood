import 'package:eefood/features/payment/presentation/provider/diamond_packages_state.dart';
import 'package:flutter/material.dart';

const _bgSurface = Color(0xFF1C2035);
const _primary = Color(0xFF6C63FF);
const _accent = Color(0xFF00D4FF);
const _gold = Color(0xFFFF6B35);
const _textHigh = Color(0xFFF0F2FF);
const _textMid = Color(0xFF8B90B8);
const _border = Color(0xFF252A45);

const _gradientSelected = LinearGradient(
  colors: [_primary, _accent],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const _gradientGold = LinearGradient(
  colors: [Color(0xFFFFB830), Color(0xFFFF6B35)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

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

  bool get _hasBonus => package.bonusDiamond > 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? _gold : _border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _gold.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Subtle top-left glow when selected
              if (isSelected)
                Positioned(
                  top: -20,
                  left: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _gold.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

              // Card content
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Diamond amount row ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('💎', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 5),
                        Text(
                          '${package.diamondAmount}',
                          style:  TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // ── Bonus badge or spacer ──
                    if (_hasBonus)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          gradient: _gradientGold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '+${package.bonusDiamond} bonus',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 18), // keep height consistent

                    const SizedBox(height: 6),

                    // ── Total line (only when bonus exists) ──
                    if (_hasBonus)
                      Text(
                        'Tổng: ${package.totalDiamond}',
                        style: const TextStyle(
                          color: _textMid,
                          fontSize: 10,
                          height: 1.2,
                        ),
                      )
                    else
                      const SizedBox.shrink(),

                    const Spacer(),

                    // ── Price chip ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _border),
                      ),
                      child: Text(
                        package.displayPrice,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── Select indicator ──
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        gradient: isSelected ? _gradientSelected : null,
                        color: isSelected ? null : theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : _border,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isSelected) ...[
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 11,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            isSelected ? 'Đã chọn' : 'Chọn gói',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? Colors.white : _textMid,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
