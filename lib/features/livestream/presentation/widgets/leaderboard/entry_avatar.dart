import 'package:flutter/material.dart';

class EntryAvatar extends StatelessWidget {
  final String? avatarUrl;
  final int rank;

  const EntryAvatar({super.key, required this.avatarUrl, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: rank == 1
              ? const Color(0xFFFFD700)
              : rank == 2
              ? const Color(0xFFC0C0C0)
              : rank == 3
              ? const Color(0xFFCD7F32)
              : Colors.white24,
          width: rank <= 3 ? 2 : 1.5,
        ),
      ),
      child: ClipOval(
        child: avatarUrl != null && avatarUrl!.isNotEmpty
            ? Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _defaultAvatar(),
              )
            : _defaultAvatar(),
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: Colors.grey[800],
      child: const Icon(Icons.person, color: Colors.white54, size: 22),
    );
  }
}
