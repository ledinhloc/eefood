import 'dart:async';
import 'package:eefood/features/auth/presentation/screens/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();

    // Sau 3 giây chuyển sang WelcomePage
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 50),

          // Logo ở giữa
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 500,
                height: 500,
                fit: BoxFit.contain,
              ),
              
            ],
          ),
          // Loading spinner ở dưới
          const Padding(padding: EdgeInsets.only(bottom: 40),
            child: SpinKitCircle(
              color: Colors.orange,
              size: 50.0,
            ),
          ),
        ],
        
      )),
    );
  }
}