import 'package:flutter/material.dart';
import 'package:eefood/features/post/presentation/widgets/post_card.dart';

class FooterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onPressed;

  const FooterButton({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {  
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      splashColor: kPrimaryColor.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color ?? Colors.grey,),
            if (label.isNotEmpty) const SizedBox(width: 6),
            if (label.isNotEmpty)
              Text(
                label,
                style: TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
