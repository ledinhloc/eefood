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
            SendBar(state: state, balance: balance),
        ],
      ),
    );
  }
}
