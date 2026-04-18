import 'package:flutter/material.dart';

import '../../../data/model/live_poll_response.dart';
import '../../../domain/enum/poll_status.dart';

class LivePollBanner extends StatelessWidget {
  final LivePollResponse poll;
  final VoidCallback onTap;

  const LivePollBanner({
    super.key,
    required this.poll,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: poll.status.color.withOpacity(0.7),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.poll_outlined,
              color: poll.status.color,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poll.question,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    poll.status.text,
                    style: TextStyle(
                      color: poll.status.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}