import 'package:eefood/app_routes.dart';
import 'package:eefood/features/livestream/presentation/provider/live_gift_state.dart';
import 'package:eefood/features/livestream/presentation/widgets/live_gift/balance_header.dart';
import 'package:eefood/features/livestream/presentation/widgets/live_gift/gift_grid.dart';
import 'package:eefood/features/livestream/presentation/widgets/live_gift/send_bar.dart';
import 'package:eefood/features/livestream/presentation/widgets/live_gift/sheet_handle.dart';
import 'package:flutter/material.dart';

class LiveGiftSheetContent extends StatelessWidget {
  final LiveGiftState state;
  final int balance;
  const LiveGiftSheetContent({
    super.key,
    required this.state,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final canAfford = state.selectedGift != null
        ? state.canAfford(balance)
        : true;

    return Container(
      height: MediaQuery.of(context).size.height * 0.52,
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          SheetHandle(),
          BalanceHeader(balance: balance),
          const SizedBox(height: 8),
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF7C6AFF)),
                  )
                : GiftGrid(gifts: state.gifts, selected: state.selectedGift),
          ),
          if (state.selectedGift != null)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SendBar(state: state, balance: balance),
                if (!canAfford)
                  SafeArea(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F1A),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, AppRoutes.recharge);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C6AFF),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Text(
                            '💎',
                            style: TextStyle(fontSize: 16),
                          ),
                          label: const Text(
                            'Nạp kim cương',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
