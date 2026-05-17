import 'package:eefood/features/livestream/data/model/live_subtitle_message.dart';
import 'package:flutter/material.dart';

class LiveSubtitleOverlay extends StatelessWidget {
  final LiveSubtitleMessage subtitle;

  const LiveSubtitleOverlay({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    if (subtitle.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.14),
          ),
        ),
        child: Text(
          subtitle.text,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
