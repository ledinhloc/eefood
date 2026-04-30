import 'package:flutter/material.dart';

class StepTimeInfo extends StatelessWidget {
  final int minutes;
  const StepTimeInfo({super.key, required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D9CDB).withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2D9CDB).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time_rounded,
            color: Color(0xFF2D9CDB),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Thời gian bước: $minutes phút',
            style: const TextStyle(
              color: Color(0xFF2D9CDB),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
