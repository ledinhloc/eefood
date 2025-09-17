import 'dart:io';

import 'package:flutter/material.dart';

class ImagePickerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? path;
  final bool isLocal;
  final bool isVideo;
  final VoidCallback onPressed;
  const ImagePickerButton({
    super.key,
    required this.label,
    required this.icon,
    this.path,
    this.isLocal = false,
    this.isVideo = false,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500),),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onPressed,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
            ),
            child: _buildContent(),
          ),
        )
      ],
    );
  }

  Widget _buildContent() {
    if(path!=null && path!.isNotEmpty){
      return isVideo ? _buildVideoPreview() : _buildImagePreview();
    }
    return Icon(icon, size: 40, color: Colors.white70,);
  }

  Widget _buildImagePreview() {
    final Widget imageWidget = isLocal 
    ? Image.file(File(path!), fit: BoxFit.cover)
    : Image.network(path!, fit: BoxFit.cover);
    return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageWidget,
    );
  }

  Widget _buildVideoPreview() {
    final Widget thumbnail = isLocal
    ? Image.file(File(path!), fit: BoxFit.cover)
    : Image.network(path!, fit: BoxFit.cover);

    return Stack(
      alignment: Alignment.center,
      children: [
        const Icon(Icons.play_circle_fill, size: 50, color: Colors.white70,),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Opacity(opacity: 0.7, child: thumbnail),
        )
      ],
    );
  }
}
