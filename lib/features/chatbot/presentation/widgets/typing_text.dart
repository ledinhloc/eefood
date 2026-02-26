import 'dart:async';

import 'package:flutter/material.dart';

class TypingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration speed;
  final bool animate;

  const TypingText({
    super.key,
    required this.text,
    this.style,
    this.speed = const Duration(milliseconds: 18),
    this.animate = false,
  });

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> {
  Timer? _timer;
  int _displayedLength = 0;
  String _targetText = '';

  @override
  void initState() {
    super.initState();
    if (widget.animate && widget.text.isNotEmpty) {
      _targetText = widget.text;
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(TypingText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.animate) {
      _timer?.cancel();
      return;
    }

    if (widget.text != oldWidget.text) {
      _targetText = widget.text;

      // Nếu text mới là phần mở rộng (streaming append), tiếp tục timer
      if (widget.text.startsWith(oldWidget.text)) {
        if (_timer == null || !_timer!.isActive) {
          _startTimer();
        }
        // Timer đang chạy → tự động theo kịp target
      } else {
        // Text hoàn toàn mới → reset
        _timer?.cancel();
        _displayedLength = 0;
        _startTimer();
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.speed, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_displayedLength < _targetText.length) {
        // Tăng tốc nếu đang bị lag xa so với target
        final lag = _targetText.length - _displayedLength;
        final step = lag > 20 ? 3 : 1; // catch-up mode
        setState(() {
          _displayedLength = (_displayedLength + step).clamp(
            0,
            _targetText.length,
          );
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate || widget.text.isEmpty) {
      return Text(widget.text, style: widget.style);
    }

    final display = _targetText.substring(
      0,
      _displayedLength.clamp(0, _targetText.length),
    );

    return Text(display, style: widget.style);
  }
}
