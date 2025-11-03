import 'package:eefood/features/profile/presentation/widgets/personal_header/start_item.dart';
import 'package:flutter/material.dart';
import 'package:eefood/core/widgets/user_avatar.dart';
import 'package:eefood/features/auth/domain/entities/user.dart';

class PersonalUserInfo extends StatelessWidget {
  final User user;

  const PersonalUserInfo({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Hero(
            tag: 'user_avatar_${user.username}',
            child: UserAvatar(
              username: user.username,
              isLocal: false,
              radius: 55,
              url: user.avatarUrl,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.username,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildStats(),
          const SizedBox(height: 16),
          _buildFollowButton(),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const StartItem(title: 'Bài viết', value: '128'),
          VerticalDivider(),
          const StartItem(title: 'Người theo dõi', value: '5.8K'),
          VerticalDivider(),
          const StartItem(title: 'Đang theo dõi', value: '120'),
        ],
      ),
    );
  }

  Widget _buildFollowButton() {
    return SizedBox(
      width: 180,
      height: 44,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE67E22),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: const Text(
          'Theo dõi',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
