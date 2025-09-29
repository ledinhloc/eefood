import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:eefood/main.dart'; // Giả sử navigatorKey nằm ở đây

class LoadingOverlay {
  static final LoadingOverlay _instance = LoadingOverlay._internal();
  factory LoadingOverlay() => _instance;
  LoadingOverlay._internal();

  OverlayEntry? _overlayEntry;
  int _showCount = 0;

  void show() {
    if (navigatorKey.currentState == null) return; // Tránh lỗi nếu app chưa build xong
    _showCount++;
    if (_showCount == 1) {
      _overlayEntry = OverlayEntry(
        builder: (context) => Container(
          color: Colors.black54,
          alignment: Alignment.center,
          child: const SpinKitCircle(color: Colors.orange, size: 60),
        ),
      );
      navigatorKey.currentState!.overlay!.insert(_overlayEntry!);
    }
  }

  void hide() {
    if (_showCount > 0) {
      _showCount--;
      if (_showCount == 0 && _overlayEntry != null) {
        _overlayEntry!.remove();
        _overlayEntry = null;
      }
    }
  }
}