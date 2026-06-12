import 'package:flutter/material.dart';

class TypeBadge extends StatelessWidget {
  final String type;
  final dynamic cfg;
  const TypeBadge({super.key, required this.type, required this.cfg});

  @override
  Widget build(BuildContext context) {
    final labels = {'TOPUP': 'Nạp', 'SPEND': 'Dùng', 'REFUND': 'Hoàn trả'};
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (cfg.bg as Color),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        labels[type] ?? type,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: cfg.iconColor as Color,
        ),
      ),
    );
  }
}
