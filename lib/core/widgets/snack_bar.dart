import 'dart:async';
import 'package:flutter/material.dart';

/* Custom snack bar*/
/* Cách dùng: showCustomSnackBar(context, 'Đã lưu món ăn!', isError: false); */
Future<bool> showCustomSnackBar(
    BuildContext context,
    String message, {
      bool isError = false,
    }) {
  final completer = Completer<bool>();
  final messenger = ScaffoldMessenger.of(context);

  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    backgroundColor: Colors.transparent,
    elevation: 0,
    dismissDirection: DismissDirection.horizontal,
    duration: const Duration(seconds: 3),

    content: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isError
              ? [
            Colors.red.shade400,
            Colors.red.shade600,
          ]
              : [
            Colors.orange.shade400,
            Colors.deepOrange.shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isError ? Colors.red : Colors.orange).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon với animation
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // Message
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Close button
          GestureDetector(
            onTap: () {
              if (!completer.isCompleted) completer.complete(true);
              messenger.hideCurrentSnackBar(reason: SnackBarClosedReason.action);
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  messenger.showSnackBar(snackBar);

  // Auto dismiss
  Future.delayed(const Duration(seconds: 2), () {
    if (!completer.isCompleted) completer.complete(false);
    messenger.hideCurrentSnackBar(reason: SnackBarClosedReason.timeout);
  });

  return completer.future;
}