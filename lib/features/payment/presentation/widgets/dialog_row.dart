import 'package:flutter/widgets.dart';

const _textMid = Color(0xFF8B90B8);

class DialogRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool bold;
  const DialogRow({
    super.key,
    required this.label,
    required this.value,
    required this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: _textMid, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
