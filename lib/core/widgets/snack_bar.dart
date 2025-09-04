import 'package:flutter/material.dart';

/* Custom snack bar*/
/* cách dùng: showCustomSnackBar(context, 'Login failed', isError: true);   */
void showCustomSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating, // Nổi lên thay vì dính đáy
    margin: const EdgeInsets.all(16), // Khoảng cách xung quanh
    backgroundColor: isError ? Colors.redAccent : Colors.green, // Màu theo loại
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Bo tròn
      side: BorderSide(color: Colors.white70, width: 1),
    ),
    duration: const Duration(seconds: 3), // Thời gian hiển thị
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
    action: SnackBarAction(
      label: 'OK',
      textColor: Colors.white,
      onPressed: () {
        // Có thể thêm hành động nếu muốn
      },
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
