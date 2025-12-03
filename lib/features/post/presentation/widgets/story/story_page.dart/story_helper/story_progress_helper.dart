import 'dart:async';
import 'package:flutter/material.dart';

/// Helper class quản lý progress của story
class StoryProgressHelper {
  Timer? _timer;
  double _progress = 0.0;
  int _tick = 0;
  int _totalTicks = 0;
  bool _isPaused = false;

  final VoidCallback onProgressUpdate;
  final VoidCallback onComplete;

  StoryProgressHelper({
    required this.onProgressUpdate,
    required this.onComplete,
  });

  double get progress => _progress;
  bool get isPaused => _isPaused;

  void start({Duration? videoDuration}) {
    if (videoDuration == null || videoDuration == Duration.zero) {
      videoDuration = const Duration(seconds: 8);
    }

    _timer?.cancel();
    _isPaused = false;
    _tick = 0;
    _progress = 0.0;

    final duration = videoDuration.inSeconds == 0
        ? const Duration(seconds: 8)
        : videoDuration;

    _totalTicks = duration.inMilliseconds ~/ 50;

    _timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (_isPaused) return;

      _tick++;

      if (_tick >= _totalTicks) {
        _progress = 1.0;
        t.cancel();
        onProgressUpdate();
        onComplete();
        return;
      }

      _progress = _tick / _totalTicks;
      onProgressUpdate();
    });
    debugPrint("${_timer?.tick}");
  }

  void pause() {
    if (_isPaused) return;
    _isPaused = true;
    debugPrint("Progress paused");
  }

  void resume() {
    if (!_isPaused) return;
    _isPaused = false;
    debugPrint("Progress resumed");
  }

  void reset() {
    _progress = 0.0;
    _tick = 0;
    _totalTicks = 0;
    _timer?.cancel();
    _isPaused = false;
  }

  void dispose() {
    _timer?.cancel();
  }
}
