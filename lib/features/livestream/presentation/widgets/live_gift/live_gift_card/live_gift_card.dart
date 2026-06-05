import 'package:eefood/features/livestream/data/model/send_gift_response.dart';
import 'package:eefood/features/livestream/presentation/widgets/live_gift/live_gift_card/avatar_chip.dart';
import 'package:eefood/features/livestream/presentation/widgets/live_gift/live_gift_card/gift_visual.dart';
import 'package:eefood/features/livestream/presentation/widgets/live_gift/live_gift_card/quantity_pill.dart';
import 'package:eefood/features/livestream/presentation/widgets/live_gift/live_gift_card/shimmer_overlay.dart';
import 'package:flutter/material.dart';

class LiveGiftCard extends StatelessWidget {
  final SendGiftResponse gift;
  final AnimationController shimmerCtrl;
  final AnimationController particleCtrl;
  const LiveGiftCard({
    super.key,
    required this.gift,
    required this.shimmerCtrl,
    required this.particleCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 0),
      padding: const EdgeInsets.fromLTRB(4, 5, 14, 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0533), Color(0xFF2D1B69)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(50),
          bottomRight: Radius.circular(50),
          topLeft: Radius.circular(50),
          bottomLeft: Radius.circular(50),
        ),
        border: Border.all(
          color: const Color(0xFF9C7EFF).withValues(alpha: 0.7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C6AFF).withValues(alpha: 0.45),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: const Color(0xFFE040FB).withValues(alpha: 0.2),
            blurRadius: 32,
            spreadRadius: 6,
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              AvatarChip(
                name: gift.senderName ?? '?',
                imageUrl: gift.senderImageUrl,
              ),
              const SizedBox(width: 8),

              // Sender + label
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    gift.senderName ?? 'Người dùng',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFFB86C), Color(0xFFFF79C6)],
                    ).createShader(bounds),
                    child: const Text(
                      'đã tặng quà ✨',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),

              // Gift visual với particles
              GiftVisual(gift: gift, particleCtrl: particleCtrl),

              // Quantity
              if ((gift.quantity ?? 1) > 1) ...[
                const SizedBox(width: 6),
                QuantityPill(quantity: gift.quantity!),
              ],
            ],
          ),
          // Shimmer overlay - positioned over everything
          ShimmerOverlay(ctrl: shimmerCtrl),
        ],
      ),
    );
  }
}
