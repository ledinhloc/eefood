import 'package:eefood/core/widgets/user_avatar.dart';
import 'package:eefood/features/auth/domain/entities/user.dart';
import 'package:eefood/features/auth/presentation/widgets/auth_button.dart';
import 'package:eefood/features/profile/presentation/widgets/start_item.dart';
import 'package:flutter/material.dart';

class PersonalUserHeader extends StatelessWidget {
  final User? user;
  const PersonalUserHeader({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final String username = user?.username ?? '';
    final String avatarUrl = user?.avatarUrl ?? '';
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Background image
        Container(
          height: 280,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/images/food_background.jpg',
              ), // Thay bằng ảnh của bạn
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
        ),

        // Avatar positioned at bottom center
        Positioned(
          bottom: -50,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: UserAvatar(
              username: username,
              isLocal: false,
              radius: 55,
              url: avatarUrl,
            ),
          ),
        ),

        // Content below avatar
        Positioned(
          top: 290,
          left: 0,
          right: 0,
          child: Column(
            children: [
              const SizedBox(height: 65),

              // Username
              Text(
                'Le Dinh Loc',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              // Stats row
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    StatItem(title: 'Posts', value: '128'),
                    _VerticalDivider(),
                    StatItem(title: 'Followers', value: '5.8K'),
                    _VerticalDivider(),
                    StatItem(title: 'Following', value: '120'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Follow button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE67E22),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Theo dõi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 32, width: 1, color: Colors.grey[300]);
  }
}
