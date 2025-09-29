import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaPickerCard extends StatefulWidget {
  final bool isImage;
  final File? file;
  final String? url;
  final VoidCallback onPick;

  const MediaPickerCard({
    Key? key,
    required this.isImage,
    required this.file,
    required this.url,
    required this.onPick,
  }) : super(key: key);

  @override
  State<MediaPickerCard> createState() => _MediaPickerCardState();
}

class _MediaPickerCardState extends State<MediaPickerCard> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (!widget.isImage &&
        (widget.file != null || (widget.url?.isNotEmpty ?? false))) {
      if (widget.file != null) {
        _controller = VideoPlayerController.file(widget.file!)
          ..initialize().then((_) => setState(() {}));
      } else {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url!))
          ..initialize().then((_) => setState(() {}));
      }
    }
  }

  @override
  void dispose() {
    _controller?.pause();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMedia =
        widget.file != null || (widget.url != null && widget.url!.isNotEmpty);

    return GestureDetector(
      onTap: () async {
        if (_controller != null && _controller!.value.isInitialized) {
          if (_controller!.value.isPlaying) {
            await _controller!.pause();
          } else {
            await _controller!.play();
          }
          setState(() {});
        } else {
          widget.onPick();
        }
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: hasMedia
            ? Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.isImage) ...[
                    if (widget.file != null)
                      Image.file(widget.file!, fit: BoxFit.cover)
                    else if (widget.url != null)
                      Image.network(widget.url!, fit: BoxFit.cover),
                  ] else ...[
                    if (_controller != null && _controller!.value.isInitialized)
                      FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller!.value.size.width,
                          height: _controller!.value.size.height,
                          child: VideoPlayer(_controller!),
                        ),
                      )
                    else
                      const Center(child: CircularProgressIndicator()),
                    const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        size: 50,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.isImage
                          ? Icons.add_photo_alternate
                          : Icons.videocam,
                      size: 40,
                      color: Colors.grey,
                    ),
                    Text(
                      widget.isImage
                          ? 'Add recipe cover image'
                          : 'Add recipe video',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
