import 'package:flutter/material.dart';
import 'package:eefood/features/post/presentation/widgets/post_card.dart';

class FooterButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback? onPressed;

  const FooterButton({
    super.key,
    required this.icon,
    required this.label,
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
            Text(
              icon,
              style: TextStyle(
                fontSize: 15,
                color: kPrimaryColor,
              ),
            ),
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
