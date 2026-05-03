import 'package:flutter/material.dart';

class AnimateBar extends StatelessWidget {
  final double ratio;
  final Color color;
  final bool isBetter;
  const AnimateBar({
    super.key,
    required this.ratio,
    required this.color,
    required this.isBetter,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Stack(
          children: [
            Container(
              width: width,
              height: 8,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              width: (width * ratio).clamp(0.0, width),
              height: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isBetter
                      ? [color, color.withOpacity(0.7)]
                      : [color.withOpacity(0.6), color.withOpacity(0.4)],
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: isBetter
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }
}
