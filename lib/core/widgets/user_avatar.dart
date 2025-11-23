import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eefood/app_routes.dart';
import 'package:flutter/material.dart';
/* widget avatar user*/

class UserAvatar extends StatelessWidget {
  // final ImageProvider? imageProvider;
  final String? url; // có thể là link hoặc đường dẫn file local
  final bool isLocal; // true: file trong máy, false: link online
  final String username;
  final double radius;
  final Color backgroundColor;
  const UserAvatar({
    super.key,
    required this.username,
    this.url,
    this.isLocal = false,
    this.radius = 40,
    this.backgroundColor = Colors.blueAccent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.mediaView,
          arguments: {
            // 'isVideo': true,
            // 'url': 'https://res.cloudinary.com/dmymncmab/video/upload/v1745543504/file_jkoy5f.mp4',
            'isVideo': false,
            'isLocal': isLocal,
            'url': url,
          },
        );
      },
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        backgroundImage: url != null
            ? ((isLocal)
                  ? FileImage(File(url!))
                  : CachedNetworkImageProvider(url!,))
            : null,
        child: (url == null || url!.isEmpty)
            ? Text(
                username.isNotEmpty ? username[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: radius / 2,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }
}
