import 'package:eefood/features/livestream/presentation/provider/live_gift_cubit.dart';
import 'package:eefood/features/livestream/presentation/widgets/live_gift/step_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuantityStepper extends StatelessWidget {
  final int quantity;
  const QuantityStepper({super.key, required this.quantity});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StepButton(
            icon: Icons.remove,
            onTap: () => context.read<LiveGiftCubit>().decrementQuantity(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'x$quantity',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          StepButton(
            icon: Icons.add,
            onTap: () => context.read<LiveGiftCubit>().incrementQuantity(),
          ),
        ],
      ),
    );
  }
}
