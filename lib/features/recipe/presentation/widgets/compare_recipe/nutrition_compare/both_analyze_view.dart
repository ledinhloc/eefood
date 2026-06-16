import 'dart:math';

import 'package:flutter/material.dart';

class BothAnalyzeView extends StatelessWidget {
  final AnimationController rotateController;
  final Animation<double> pulseAnim;
  const BothAnalyzeView({
    super.key,
    required this.rotateController,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 12),
          ScaleTransition(
            scale: pulseAnim,
            child: AnimatedBuilder(
              animation: rotateController,
              builder: (_, child) => Transform.rotate(
                angle: rotateController.value * 2 * pi,
                child: child,
              ),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const SweepGradient(
                    colors: [
                      Color(0x1AE8534A),
                      Color(0xFFE8534A),
                      Color(0xFF2C9E6E),
                      Color(0x1A2C9E6E),
                    ],
                    stops: [0.0, 0.4, 0.7, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE8534A).withOpacity(0.2),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 18,
                      color: Color(0xFF5C6BC0),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'AI đang phân tích cả 2 công thức',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Quá trình này có thể mất vài giây...',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
