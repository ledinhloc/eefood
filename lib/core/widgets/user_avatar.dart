
import 'dart:io';

import 'package:eefood/app_routes.dart';
import 'package:flutter/material.dart';
/* widget avatar user*/

class UserAvatar extends StatelessWidget {
  final ImageProvider? imageProvider;
  final String username;
  final double radius;
  final Color backgroundColor;
  const UserAvatar({
    super.key,
    required this.username,
    this.imageProvider,
    this.radius = 40,
    this.backgroundColor = Colors.blueAccent
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.mediaView,
        arguments: {
          'isVideo': true,
          'url': 'https://res.cloudinary.com/dmymncmab/video/upload/v1745543504/file_jkoy5f.mp4',
          // 'isVideo': false,
          // 'url': 'https://cdn.tgdd.vn/Files/2022/04/13/1425497/tim-hieu-ve-ti-le-man-hinh-tren-smartphone-va-su-p-4.jpg',
          },
        );
      },
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        backgroundImage: imageProvider,
        child: imageProvider == null
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
