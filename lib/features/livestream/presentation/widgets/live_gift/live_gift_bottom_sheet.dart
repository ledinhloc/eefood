import 'package:eefood/features/livestream/presentation/provider/live_gift_cubit.dart';
import 'package:eefood/features/livestream/presentation/provider/live_gift_state.dart';
import 'package:eefood/features/livestream/presentation/widgets/live_gift/live_gift_sheet_content.dart';
import 'package:eefood/features/payment/presentation/provider/wallet_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LiveGiftBottomSheet extends StatelessWidget {
  const LiveGiftBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, int>(
      builder: (context, balance) {
        return BlocConsumer<LiveGiftCubit, LiveGiftState>(
          listenWhen: (prev, curr) => prev.sendError != curr.sendError,
          listener: (context, state) {
            if (state.sendError != null) {
              _showInsufficientDialog(context, state.sendError!);
            }
          },
          builder: (context, state) {
            return LiveGiftSheetContent(state: state, balance: balance);
          },
        );
      },
    );
  }

  void _showInsufficientDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('💎', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text(
              'Không đủ kim cương',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Đồng ý',
              style: TextStyle(color: Color(0xFF7C6AFF)),
            ),
          ),
        ],
      ),
    );
  }
}
