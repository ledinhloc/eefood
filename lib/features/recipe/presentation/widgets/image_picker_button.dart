import 'dart:io';

import 'package:flutter/material.dart';

class ImagePickerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final File? file;
  final String? networkImage;
  final String? networkVideo;
  final VoidCallback onPressed;
  final bool isVideo;
  const ImagePickerButton({
    super.key,
    required this.label,
    required this.icon,
    this.file,
    this.networkImage,
    this.networkVideo,
    required this.onPressed,
    this.isVideo = false,
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
    if (file != null) {
      return _buildFilePreview();
    } else if (networkImage != null && networkImage!.isNotEmpty && !isVideo) {
      return _buildNetworkImagePreview();
    } else if (networkVideo != null && networkVideo!.isNotEmpty && isVideo) {
      return _buildNetworkVideoPreview();
    } else {
      return Icon(icon, size: 40, color: Colors.grey);
    }
  }

  Widget _buildFilePreview() {
    return isVideo
        ? Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.play_circle_fill, size: 50, color: Colors.white70),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Opacity(
                  opacity: 0.7,
                  child: Image.file(file!, fit: BoxFit.cover),
                ),
              ),
            ],
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(file!, fit: BoxFit.cover),
          );
  }

  Widget _buildNetworkImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(networkImage!, fit: BoxFit.cover),
    );
  }

  Widget _buildNetworkVideoPreview() {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Icon(Icons.play_circle_fill, size: 50, color: Colors.white70),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Opacity(
            opacity: 0.7,
            child: Image.network(networkVideo!, fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }
}
