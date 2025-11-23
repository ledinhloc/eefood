import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:video_player/video_player.dart';

class MediaEditorPage extends StatefulWidget {
  final bool isImage;
  final File? file;
  final bool isForStory;
  final bool isMultiMode;

  const MediaEditorPage({
    super.key,
    required this.file,
    required this.isImage,
    this.isForStory = false,
    this.isMultiMode = false,
  });

  @override
  State<MediaEditorPage> createState() => _MediaEditorPageState();
}

class _MediaEditorPageState extends State<MediaEditorPage> {
  VideoPlayerController? _videoController;
  ProVideoController? _proVideoController;

  @override
  void initState() {
    super.initState();
    if (!widget.isImage && widget.file != null) {
      _initializeVideo();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.file(widget.file!);
    await _videoController!.initialize();
    _videoController!.setLooping(false);
    _videoController!.setVolume(1.0);

    // Khởi tạo ProVideoController
    _proVideoController = ProVideoController(
      videoPlayer: _buildVideoPlayer(),
      initialResolution: _videoController!.value.size,
      videoDuration: _videoController!.value.duration,
      fileSize: await widget.file!.length(),
      bitrate: 0, // Bạn có thể tính bitrate nếu muốn
      thumbnails: [],
    );

    setState(() {});
  }

  Future<File?> _saveEditedImage(Uint8List bytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final filePath = '${tempDir.path}/edited_story_$timestamp.jpg';
      final editedFile = File(filePath);

      await editedFile.writeAsBytes(bytes);

      return editedFile;
    } catch (e) {
      debugPrint('Error saving edited image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isImage) {
      if (widget.file == null) return const Scaffold();
      return Scaffold(
        body: ProImageEditor.file(
          widget.file!,
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: (bytes) async {
              final editedFile = await _saveEditedImage(bytes);
              if (widget.isMultiMode) {
                Navigator.pop(context, editedFile);
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  //Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pop(context, editedFile);
                });
              }
            },
          ),
        ),
      );
    } else {
      if (widget.file == null) return const Scaffold();
      return Scaffold(
        body: _proVideoController == null
            ? const Center(child: CircularProgressIndicator())
            : ProImageEditor.video(
                _proVideoController!,
                callbacks: ProImageEditorCallbacks(
                  onCompleteWithParameters: (params) async {
                    Navigator.pop(context, widget.file);
                  },
                  videoEditorCallbacks: VideoEditorCallbacks(
                    onPause: _videoController!.pause,
                    onPlay: _videoController!.play,
                    onMuteToggle: (isMuted) {
                      _videoController!.setVolume(isMuted ? 0 : 1);
                    },
                  ),
                ),
              ),
      );
    }
  }

  Widget _buildVideoPlayer() {
    return Center(
      child: AspectRatio(
        aspectRatio: _videoController!.value.size.aspectRatio,
        child: VideoPlayer(_videoController!),
      ),
    );
  }
}
