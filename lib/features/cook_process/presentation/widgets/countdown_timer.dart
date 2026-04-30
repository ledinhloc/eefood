import 'dart:async';

import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final int seconds;
  final ValueChanged<bool>? onRunningChanged;
  final VoidCallback? onFinished;
  const CountdownTimer({
    super.key,
    required this.seconds,
    this.onRunningChanged,
    this.onFinished,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late int _remaining;
  Timer? _timer;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
  }

  @override
  void didUpdateWidget(CountdownTimer old) {
    super.didUpdateWidget(old);
    if (old.seconds != widget.seconds) {
      _timer?.cancel();
      final wasRunning = _running;
      setState(() {
        _remaining = widget.seconds;
        _running = false;
      });
      if (wasRunning) widget.onRunningChanged?.call(false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    } else {
      if (_remaining <= 0) setState(() => _remaining = widget.seconds);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_remaining <= 0) {
          _timer?.cancel();
          setState(() => _running = false);
          widget.onRunningChanged?.call(false);
          widget.onFinished?.call();
        } else {
          setState(() => _remaining--);
        }
      });
      setState(() => _running = true);
      widget.onRunningChanged?.call(true);
    }
  }

  String get _formatted {
    final m = _remaining ~/ 60;
    final s = _remaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDone = _remaining <= 0;
    final color = isDone
        ? Colors.green
        : _remaining < 30
        ? Colors.red
        : const Color(0xFFFF6B35);
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDone
                  ? Icons.check_circle_rounded
                  : _running
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: color,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              isDone ? 'Xong!' : _formatted,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 15,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
