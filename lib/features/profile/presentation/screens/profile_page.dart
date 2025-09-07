import 'package:eefood/app_routes.dart';
import 'package:eefood/features/auth/presentation/screens/welcome_page.dart';
import 'package:eefood/features/profile/presentation/provider/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/auth_usecases.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});
  final  _logout = getIt<Logout>();
  final _getCurrentUser = getIt<GetCurrentUser>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(getIt<GetCurrentUser>())..loadProfile(),
      child:  BlocBuilder<ProfileCubit, User?> (
        builder: (context, user) {
          if (user == null) {
            return const Center(child: CircularProgressIndicator(),);
          }
          return  Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Profile Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      // backgroundColor: Colors.amber,
                      backgroundImage: NetworkImage(user.avatarUrl ?? ''),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                        user.username,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Community member",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.editProfile);
                          },
                          child: const Text("Edit profile"),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Account section
                const Text("Account", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text("Current Plan"),
                  trailing: const Text("Free"),
                ),

                Card(
                  color: Colors.amber[50],
                  child: ListTile(
                    leading: const Icon(Icons.star, color: Colors.purple),
                    title: const Text(
                        "Try all Plus features for free during your 7-day trial period!"),
                    trailing: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                      ),
                      child: const Text("Try for free"),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Text("Account Management",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ListTile(
                  leading: const Icon(Icons.favorite_border),
                  title: const Text("Food preferences"),
                  subtitle: const Text("Only applicable to the For you tab"),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.foodPreference),
                ),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text("Restore purchases"),
                ),

                const SizedBox(height: 16),
                const Text("System", style: TextStyle(fontWeight: FontWeight.bold)),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text("Languages"),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.language),
                ),
                ListTile(
                  leading: const Icon(Icons.scale),
                  title: const Text("Measurement System"),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_none),
                  title: const Text("Notifications"),
                ),
                ListTile(
                  leading: const Icon(Icons.brightness_6_outlined),
                  title: const Text("Display"),
                ),

                const SizedBox(height: 16),
                const Text("Support", style: TextStyle(fontWeight: FontWeight.bold)),
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: const Text("Feedback"),
                ),
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: const Text("Report a bug"),
                ),

                const SizedBox(height: 16),
                const Text("Recommend",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ListTile(
                  leading: const Icon(Icons.thumb_up_outlined),
                  title: const Text("Tell a friend!"),
                ),
                ListTile(
                  leading: const Icon(Icons.star_border),
                  title: const Text("Rate app"),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.orange,
              child: const Icon(Icons.notifications),
            ),
          );
        }
      )
    );
  }
}