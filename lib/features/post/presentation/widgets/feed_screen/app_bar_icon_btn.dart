import 'package:flutter/material.dart';

class AppBarIconBtn extends StatelessWidget {
  final Color color;
  final Color iconColor;
  final IconData icon;
  final VoidCallback onTap;
  const AppBarIconBtn({
    super.key,
    required this.color,
    required this.iconColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 19, color: iconColor),
        ),
      ),
    );
  }
}
