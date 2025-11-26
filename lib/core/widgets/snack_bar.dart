import 'dart:async';

import 'package:flutter/material.dart';

/* Custom snack bar*/
/* cách dùng: showCustomSnackBar(context, 'Login failed', isError: true);   */
Future<bool> showCustomSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final completer = Completer<bool>();

  final messenger = ScaffoldMessenger.of(context);

  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(16),
    backgroundColor: isError ? Colors.red : Colors.green,
    dismissDirection: DismissDirection.none,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Colors.white70, width: 1),
    ),
    duration: const Duration(seconds: 3),

    // Bấm OK
    action: SnackBarAction(
      label: 'OK',
      textColor: Colors.white,
      onPressed: () {
        if (!completer.isCompleted) completer.complete(true);
        messenger.hideCurrentSnackBar(reason: SnackBarClosedReason.action);
      },
    ),

    // Nội dung
    content: Row(
      children: [
        Icon(
          isError ? Icons.error_outline : Icons.check_circle_outline,
          color: Colors.white,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );

  messenger.showSnackBar(snackBar);

  // Tự đóng bằng timer
  Future.delayed(const Duration(seconds: 3), () {
    if (!completer.isCompleted) completer.complete(false);
    messenger.hideCurrentSnackBar(reason: SnackBarClosedReason.timeout);
  });

  return completer.future;
}
