import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';

class BetterPlayerUtils {
  static BetterPlayerController create({
    required String url,
    bool autoPlay = false,
    bool looping = true,
    bool mute = true,
    double aspectRatio = 9 / 16,
    bool cache = true,
  }) {
    final configuration = BetterPlayerConfiguration(
      autoPlay: autoPlay,
      looping: looping,
      fit: BoxFit.cover,
      aspectRatio: aspectRatio,
      controlsConfiguration: const BetterPlayerControlsConfiguration(
        showControls: false,
        enableProgressBar: false,
        enablePlayPause: false,
      ),
      autoDetectFullscreenDeviceOrientation: false,
      handleLifecycle: false,
      autoDispose: false, // Không tự động dispose
      expandToFill: true, // Fill màn hình
      placeholder: Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      ),
      // Giảm lag khi chuyển story
      eventListener: null,
    );

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      cacheConfiguration: cache
          ? const BetterPlayerCacheConfiguration(
              useCache: true,
              maxCacheSize: 200 * 1024 * 1024, // 200MB
              preCacheSize: 10 * 1024 * 1024, // Tăng lên 10MB để load mượt hơn
              maxCacheFileSize: 50 * 1024 * 1024, // 50MB per file
            )
          : null,
      // Buffer configuration để giảm lag
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: 2000, // Buffer tối thiểu 2s
        maxBufferMs: 10000, // Buffer tối đa 10s
        bufferForPlaybackMs: 1000, // 1s buffer trước khi play
        bufferForPlaybackAfterRebufferMs: 2000, // 2s sau khi rebuffer
      ),
    );

    final controller = BetterPlayerController(
      configuration,
      betterPlayerDataSource: dataSource,
    );

    if (mute) {
      controller.setVolume(0);
    }

    return controller;
  }
}
