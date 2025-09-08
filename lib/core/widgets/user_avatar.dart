
import 'dart:io';

import 'package:flutter/material.dart';
/* widget avatar user*/

class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final File? avatarFile;
  final String username;
  final double radius;
  final Color backgroundColor;
  const UserAvatar({
    super.key,
    required this.username,
    this.avatarUrl,
    this.avatarFile,
    this.radius = 40,
    this.backgroundColor = Colors.blueAccent
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if(avatarFile != null){
      imageProvider = FileImage(avatarFile!);
    }else if(avatarUrl != null && avatarUrl!.isNotEmpty){
      imageProvider = NetworkImage(avatarUrl!);
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: imageProvider,
      child: (avatarUrl == null || avatarUrl!.isEmpty)
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
