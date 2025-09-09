
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String username;
  final double radius;
  final Color backgroundColor;
  const UserAvatar({
    super.key,
    required this.username,
    this.avatarUrl,
    this.radius = 40,
    this.backgroundColor = Colors.blueAccent
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
          ? NetworkImage(avatarUrl!)
          : null,
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
