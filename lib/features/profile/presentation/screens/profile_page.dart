import 'package:eefood/app_routes.dart';
import 'package:eefood/features/auth/presentation/screens/welcome_page.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/domain/usecases/auth_usecases.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});
  final Logout _logout = getIt<Logout>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile'),
        actions: [
          const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.purple[100],
                child: const Text(
                  'JS',
                  style: TextStyle(fontSize: 24, color: Colors.purple),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Zain Malik',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Joined August 17, 2023',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'General',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Zain Malik'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('zainmalik02323@gmail.com'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('(628) 267-9041'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.feedback),
                    title: const Text('Feedback'),
                    onTap: () {
                      // Xử lý khi nhấn Feedback
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: const Text('Push notifications'),
                    value: true,
                    onChanged: (value) {
                      // Xử lý khi thay đổi trạng thái
                    },
                    secondary: const Icon(Icons.notifications),
                  ),
                  SwitchListTile(
                    title: const Text('SMS notifications'),
                    value: false,
                    onChanged: (value) {
                      // Xử lý khi thay đổi trạng thái
                    },
                    secondary: const Icon(Icons.sms),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              /* logout */
              ElevatedButton(
                onPressed: () {
                  _logout();
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.welcome, (route) => false);
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
              const SizedBox(height: 10),
              const Text(
                'Version 1.18.5 ',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Text(
                '@2022-23 Powered by Square',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 5),
              const Text(
                'Buyer Account terms - Square Go terms - Privacy Policy',
                style: TextStyle(fontSize: 12, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}