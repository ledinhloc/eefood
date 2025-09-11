import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/* Hien thi anh/video toan man hinh */
class MediaViewPage extends StatefulWidget {
  final String url;
  final bool isVideo; //true la video, false la anh

  const MediaViewPage({super.key, required this.url, required this.isVideo});
  @override
  State<MediaViewPage> createState() => _MediaViewPageState();
}

class _MediaViewPageState extends State<MediaViewPage> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isVideo) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize().then((_) {
          setState(() {
            _videoController?.play();
          });
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: widget.isVideo
                ? (_videoController != null &&
                          _videoController!.value.isInitialized)
                      ? AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        )
                      : const CircularProgressIndicator(color: Colors.white)
                : InteractiveViewer(
                    child: Image.network(widget.url, fit: BoxFit.contain),
                  ),
          ),
          Positioned(
            top: 30,
            left: 5,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
          // thanh hiển thị thời gian + progress bar
          if (widget.isVideo &&
              _videoController != null &&
              _videoController!.value.isInitialized)
            Positioned(
              bottom: 24,
              left: 10,
              right: 10,
              child: Row(
                children: [
                  // thời gian hiện tại
                  ValueListenableBuilder<VideoPlayerValue>(
                    valueListenable: _videoController!,
                    builder: (context, value, child) {
                      return Text(
                        _formatDuration(value.position),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: _videoController!,
                      builder: (context, VideoPlayerValue value, child) {
                        final position = value.position.inMilliseconds
                            .toDouble();
                        final duration = value.duration.inMilliseconds
                            .toDouble();

                        return SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                          ),
                          child: Slider(
                            min: 0,
                            max: duration,
                            value: position > duration ? duration : position,
                            activeColor: Colors.blue,
                            inactiveColor: Colors.white24,
                            onChanged: (newValue) {
                              _videoController!.seekTo(
                                Duration(milliseconds: newValue.toInt()),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  // tổng thời lượng video
                  Text(
                    _formatDuration(_videoController!.value.duration),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          if (widget.isVideo &&
              _videoController != null &&
              _videoController!.value.isInitialized)
            Align(
              alignment: Alignment.bottomCenter,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _videoController!.value.isPlaying
                        ? _videoController!.pause()
                        : _videoController!.play();
                  });
                },
                icon: Icon(
                  _videoController!.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
