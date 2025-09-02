import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final ImageProvider? iconImage;
  final double? iconSize;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.color,
    this.textColor,
    this.iconImage,
    this.iconSize= 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: color ?? Theme.of(context).primaryColor,
        foregroundColor: textColor ?? Theme.of(context).textTheme.bodyMedium?.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(20),
        )
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconImage != null) ...[
            Image(
              image: iconImage!,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 8),
          ] else if (icon != null) ...[
            Icon(icon, size: iconSize),
            SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor ?? Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}