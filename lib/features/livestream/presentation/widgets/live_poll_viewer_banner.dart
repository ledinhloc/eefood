import 'package:flutter/material.dart';

import '../../data/model/live_poll_response.dart';
import '../../domain/enum/poll_status.dart';

class LivePollViewerBanner extends StatelessWidget {
  final LivePollResponse poll;
  final VoidCallback onTap;

  const LivePollViewerBanner({
    super.key,
    required this.poll,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(poll.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: statusColor.withOpacity(0.7)),
        ),
        child: Row(
          children: [
            Icon(Icons.poll_outlined, color: statusColor, size: 20),
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _statusText(poll.status),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  String _statusText(PollStatus status) {
    switch (status) {
      case PollStatus.open:
        return 'Poll đang mở - nhấn để bình chọn';
      case PollStatus.closed:
        return 'Poll đã đóng - nhấn để xem kết quả';
      default:
        return 'Poll chưa mở';
    }
  }

  Color _statusColor(PollStatus status) {
    switch (status) {
      case PollStatus.open:
        return Colors.greenAccent;
      case PollStatus.closed:
        return Colors.orangeAccent;
      default:
        return Colors.white70;
    }
  }
}