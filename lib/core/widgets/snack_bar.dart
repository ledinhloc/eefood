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
  final overlay = Overlay.maybeOf(context, rootOverlay: true);

  if (overlay == null) {
    return Future.value(false);
  }

  Timer? timer;
  late OverlayEntry entry;

  void close(bool dismissedByUser) {
    timer?.cancel();
    if (entry.mounted) {
      entry.remove();
    }
    if (!completer.isCompleted) {
      completer.complete(dismissedByUser);
    }
  }

  entry = OverlayEntry(
    builder: (overlayContext) {
      final bottomInset = MediaQuery.of(overlayContext).viewInsets.bottom;
      final bottomPadding = MediaQuery.of(overlayContext).padding.bottom;

      return Positioned(
        left: 8,
        right: 8,
        bottom: bottomInset + bottomPadding + 12,
        child: SafeArea(
          top: false,
          child: Material(
            color: Colors.transparent,
            child: Dismissible(
              key: ValueKey(
                'custom_snackbar_${message}_${DateTime.now().microsecondsSinceEpoch}',
              ),
              direction: DismissDirection.horizontal,
              onDismissed: (_) => close(true),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isError
                        ? [Colors.red.shade400, Colors.red.shade600]
                        : [Colors.orange.shade400, Colors.deepOrange.shade500],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isError ? Colors.red : Colors.orange).withValues(
                        alpha: 0.3,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isError
                            ? Icons.error_outline_rounded
                            : Icons.check_circle_outline_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
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
                    GestureDetector(
                      onTap: () => close(true),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
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
            ),
          ),
        ),
      );
    },
  );

  overlay.insert(entry);

  timer = Timer(const Duration(seconds: 3), () => close(false));

  return completer.future;
}
