import 'dart:io';
import 'package:flutter/material.dart';

class CommentMediaPreview extends StatelessWidget {
  final List<File> images;
  final List<File> videos;
  final void Function(int index) onRemoveImage;
  final void Function(int index) onRemoveVideo;

  const CommentMediaPreview({
    super.key,
    required this.images,
    required this.videos,
    required this.onRemoveImage,
    required this.onRemoveVideo,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty && videos.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          ...images.asMap().entries.map(
            (entry) => _buildPreview(entry.value, true, entry.key, onRemoveImage),
          ),
          ...videos.asMap().entries.map(
            (entry) => _buildPreview(entry.value, false, entry.key, onRemoveVideo),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(File file, bool isImage, int index, void Function(int) onRemove) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 60,
          height: 60,
          margin: const EdgeInsets.only(right: 8, top: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: isImage
                ? DecorationImage(image: FileImage(file), fit: BoxFit.cover)
                : null,
            color: Colors.grey.shade300,
          ),
          child: !isImage
              ? const Center(child: Icon(Icons.videocam, size: 24))
              : null,
        ),
        Positioned(
          top: -8,
          right: 0,
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.cancel, size: 18),
            onPressed: () => onRemove(index),
          ),
        ),
      ],
    );
  }
}
