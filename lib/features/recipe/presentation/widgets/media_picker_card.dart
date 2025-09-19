import 'dart:io';
import 'package:flutter/material.dart';

class MediaPickerCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final hasMedia = file != null || (url != null && url!.isNotEmpty);

    return GestureDetector(
      onTap: onPick,
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
                  if (file != null)
                    Image.file(file!, fit: BoxFit.cover)
                  else if (url != null)
                    Image.network(url!, fit: BoxFit.cover),
                  if (!isImage)
                    const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        size: 50,
                        color: Colors.white70,
                      ),
                    ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isImage ? Icons.add_photo_alternate : Icons.videocam,
                      size: 40,
                      color: Colors.grey,
                    ),
                    Text(
                      isImage ? 'Add recipe cover image' : 'Add recipe video',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
