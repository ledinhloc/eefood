import 'package:eefood/features/livestream/presentation/provider/live_gift_cubit.dart';
import 'package:eefood/features/livestream/presentation/provider/live_gift_state.dart';
import 'package:eefood/features/livestream/presentation/widgets/live_gift/quantity_stepper.dart';
import 'package:eefood/features/livestream/presentation/widgets/live_gift/send_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SendBar extends StatelessWidget {
  final LiveGiftState state;
  final int balance;
  const SendBar({super.key, required this.state, required this.balance});

  @override
  Widget build(BuildContext context) {
    final gift = state.selectedGift!;
    final total = state.totalCost;
    final canAfford = state.canAfford(balance);
    final isSending = state.sendStatus == GiftSendStatus.sending;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F1A),
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
        ),
        child: Row(
          children: [
            // Quantity stepper
            QuantityStepper(quantity: state.quantity),
            const SizedBox(width: 12),

            // Total cost badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  gift.name ?? '',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
                Row(
                  children: [
                    const Text('💎', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 2),
                    Text(
                      '$total',
                      style: TextStyle(
                        color: canAfford
                            ? const Color(0xFFA78BFA)
                            : Colors.redAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!canAfford) ...[
                      const SizedBox(width: 4),
                      const Text(
                        '(Không đủ)',
                        style: TextStyle(color: Colors.redAccent, fontSize: 10),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            const Spacer(),

            // Send button
            SendButton(
              canAfford: canAfford,
              isSending: isSending,
              onSend: () {
                HapticFeedback.mediumImpact();
                context.read<LiveGiftCubit>().sendGift(balance);
              },
            ),
          ],
        ),
      ),
    );
  }
}
