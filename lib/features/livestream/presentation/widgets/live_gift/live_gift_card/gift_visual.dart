import 'package:eefood/features/livestream/data/model/send_gift_response.dart';
import 'package:eefood/features/livestream/presentation/widgets/live_gift/live_gift_card/particle_painter.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class GiftVisual extends StatelessWidget {
  final SendGiftResponse gift;
  final AnimationController particleCtrl;
  const GiftVisual({super.key, required this.gift, required this.particleCtrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow halo
          AnimatedBuilder(
            animation: particleCtrl,
            builder: (_, __) {
              final t = particleCtrl.value;
              return Container(
                width: 44 + t * 14,
                height: 44 + t * 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFFE040FB,
                      ).withValues(alpha: 0.5 * (1 - t)),
                      blurRadius: 20 + t * 20,
                      spreadRadius: t * 6,
                    ),
                  ],
                ),
              );
            },
          ),

          // Particles
          AnimatedBuilder(
            animation: particleCtrl,
            builder: (_, __) {
              return CustomPaint(
                painter: ParticlePainter(progress: particleCtrl.value),
                size: const Size(56, 56),
              );
            },
          ),

          // Lottie or fallback
          if (gift.animationUrl != null)
            ClipOval(
              child: SizedBox(
                width: 44,
                height: 44,
                child: Lottie.network(
                  gift.animationUrl!,
                  repeat: true,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _fallback(),
                ),
              ),
            )
          else
            _fallback(),
        ],
      ),
    );
  }

  Widget _fallback() {
    return const SizedBox(
      width: 44,
      height: 44,
      child: Center(child: Text('🎁', style: TextStyle(fontSize: 30))),
    );
  }
}

