import 'package:eefood/app_routes.dart';
import 'package:eefood/features/auth/presentation/screens/welcome_page.dart';
import 'package:eefood/features/profile/presentation/provider/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/auth_usecases.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});
  final  _logout = getIt<Logout>();
  ImageProvider? imageProvider;

  Future<void> _handlerLogout(BuildContext context) async{
    if (!context.mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _logout();
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.welcome,
            (route) => true,
      );
    }
  }

  Future<void> _handlerEditProfile(BuildContext context, User user)  async {
    final isReload = await Navigator.pushNamed(context, AppRoutes.editProfile, arguments: user);
    if (isReload == true && context.mounted) {
      context.read<ProfileCubit>().loadProfile();
    }
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(getIt<GetCurrentUser>())..loadProfile(),
      child:  BlocBuilder<ProfileCubit, User?> (
        builder: (context, user) {
          if (user == null) {
            return const Center(child: CircularProgressIndicator(),);
          }
          if(user.avatarUrl != null){
            imageProvider = NetworkImage(user.avatarUrl!);
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
                    UserAvatar(imageProvider: imageProvider, username: user.username,),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
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
                            onPressed: ()  {
                              _handlerEditProfile(context, user);
                            },
                            child: const Text("Edit profile"),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    /* Xu ly logout*/
                    IconButton(onPressed: () async =>await _handlerLogout(context), icon: Icon(Icons.exit_to_app_outlined, color: Colors.black, size: 30,),
                    )
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
                  color: Colors.red[50],
                  child: ListTile(
                    leading: const Icon(Icons.star, color: Colors.red),
                    title: const Text(
                        "Try all Plus features for free during your 7-day trial period!"),
                    trailing: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow.shade200,
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