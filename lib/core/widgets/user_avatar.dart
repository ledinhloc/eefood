
import 'dart:io';

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
    return CircleAvatar(
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
    );
  }
}
