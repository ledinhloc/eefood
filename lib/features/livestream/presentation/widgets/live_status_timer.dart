import 'package:flutter/material.dart';

import '../../../../core/utils/helpers.dart';
import '../../data/model/live_stream_response.dart';

class LiveStatusTimer extends StatefulWidget {
  final DateTime startTime;

  const LiveStatusTimer({super.key, required this.startTime});

  @override
  State<LiveStatusTimer> createState() => _LiveStatusTimerState();
}

class _LiveStatusTimerState extends State<LiveStatusTimer> {
  bool _showLiveTime = false;

  void _toggleLiveTime() {
    setState(() {
      _showLiveTime = !_showLiveTime;
    });

    if (_showLiveTime) {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showLiveTime = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleLiveTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "TRỰC TIẾP",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            if (_showLiveTime) ...[
              const SizedBox(width: 8),
              Text(
                formatDuration(DateTime.now().difference(widget.startTime)),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

extension LiveStreamStatusX on LiveStreamStatus {
  String get messageVi {
    switch (this) {
      case LiveStreamStatus.SCHEDULED:
        return 'Livestream chưa bắt đầu';
      case LiveStreamStatus.ENDED:
        return 'Livestream đã kết thúc';
      case LiveStreamStatus.CANCELLED:
        return 'Livestream đã bị hủy';
      case LiveStreamStatus.LIVE:
        return 'Livestream đang phát';
    }
  }
}
