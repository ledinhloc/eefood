import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const StepButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}
