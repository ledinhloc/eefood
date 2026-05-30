import 'package:flutter/material.dart';

class GiftPlaceholder extends StatelessWidget {
  const GiftPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A40),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(child: Text('🎁', style: TextStyle(fontSize: 28))),
    );
  }
}
