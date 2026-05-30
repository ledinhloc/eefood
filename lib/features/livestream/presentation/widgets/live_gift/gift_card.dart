import 'package:eefood/features/livestream/data/model/live_gift_item_response.dart';
import 'package:eefood/features/livestream/presentation/provider/live_gift_cubit.dart';
import 'package:eefood/features/livestream/presentation/widgets/live_gift/gift_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GiftCard extends StatelessWidget {
  final LiveGiftItemResponse gift;
  final bool isSelected;
  const GiftCard({super.key, required this.gift, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.read<LiveGiftCubit>().selectGift(gift);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF7C6AFF).withValues(alpha: 0.25)
              : const Color(0xFF1E1E30),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7C6AFF)
                : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gift image
            SizedBox(
              width: 52,
              height: 52,
              child: gift.imageUrl != null
                  ? Image.network(
                      gift.imageUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const GiftPlaceholder(),
                    )
                  : const GiftPlaceholder(),
            ),
            const SizedBox(height: 4),
            Text(
              gift.name ?? '',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('💎', style: TextStyle(fontSize: 9)),
                const SizedBox(width: 2),
                Text(
                  '${gift.diamondCost ?? 0}',
                  style: const TextStyle(
                    color: Color(0xFFA78BFA),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
