import 'package:flutter/material.dart';

class SendButton extends StatelessWidget {
  final bool canAfford;
  final bool isSending;
  final VoidCallback onSend;

  const SendButton({
    super.key,
    required this.canAfford,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (canAfford && !isSending) ? onSend : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: canAfford
              ? const LinearGradient(
                  colors: [Color(0xFF7C6AFF), Color(0xFFE040FB)],
                )
              : null,
          color: canAfford ? null : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: isSending
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎁', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    'Tặng',
                    style: TextStyle(
                      color: canAfford
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.3),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
