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
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UserAvatar(
                username: username,
                isLocal: false,
                radius: 35,
                url: avatarUrl,
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 40,
                      child: AuthButton(
                        text: 'Follow',
                        onPressed: () {},
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'John Doe',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              StatItem(title: 'Posts', value: '128'),
              StatItem(title: 'Followers', value: '5.8K'),
              StatItem(title: 'Following', value: '120'),
            ],
          ),
        ],
      ),
    );
  }
}
