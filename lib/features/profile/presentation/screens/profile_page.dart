import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/features/auth/presentation/screens/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/domain/usecases/auth_usecases.dart';
import '../../../auth/presentation/screens/login_page.dart';
import '../../../auth/presentation/screens/splash_page.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});
  final Logout _logout = getIt<Logout>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Center(
              child: Text('User Profile', style: TextStyle(color: Colors.black)),
            ),
            /* logout */
            ElevatedButton(
              onPressed: () {
                _logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SplashPage()),
                  (route) => true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* Logout */
  // Future<void> _logout() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool(AppKeys.isLoginedIn, false);
  // }
}
