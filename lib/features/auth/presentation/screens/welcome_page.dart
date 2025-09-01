import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/auth_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [secondaryColor, secondaryColor.withOpacity(0.8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/bg_welcome.png'), // Thêm hình ảnh từ assets
              const SizedBox(height: 20),
              const Text(
                'Welcome to eeFood',
                style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Experience Expert Food',
                style: TextStyle(color: textColor, fontSize: 16),
              ),
              const SizedBox(height: 40),
              AuthButton(
                text: 'Continue with Google',
                icon: Icons.g_mobiledata,
                onPressed: () {},
                color: accentColor,
              ),
              const SizedBox(height: 10),
              AuthButton(
                text: 'Get Started',
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text('I Already Have an Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}