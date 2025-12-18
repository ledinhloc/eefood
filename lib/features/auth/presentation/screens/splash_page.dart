import 'dart:async';
import 'package:eefood/app_routes.dart';
import 'package:eefood/core/utils/deep_link_service.dart';
import 'package:eefood/features/auth/presentation/screens/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../../core/di/injection.dart';
import '../../domain/usecases/auth_usecases.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final GetCurrentUser _getCurrentUser = getIt<GetCurrentUser>();
  @override
  void initState() {
    super.initState();
    // _initializeApp();
    // Sau 3 giây chuyển sang WelcomePage
    // Timer(const Duration(seconds: 3), () {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => const WelcomePage()),
    //   );
    // });
    _loadUser();
  }

  Future<void> _initializeApp() async {
    await DeepLinkService().initialize();
  }

  Future<void> _loadUser() async {
    final user = await _getCurrentUser();
    print('User: $user');
    // kiểm tra widget còn tồn tại
    // Navigator.pushReplacementNamed(context, AppRoutes.main);
    if (!mounted) return;
    if (user != null) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    }

    // Future.delayed(const Duration(milliseconds: 500), () {
    //   DeepLinkService().handlePendingLinkIfAny();
    // });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // lấy kích thước màn hình
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(), // đẩy logo xuống giữa
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: size.width, // chiếm 60% chiều ngang màn hình
                fit: BoxFit.contain,
              ),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: SpinKitCircle(color: Colors.orange, size: 50.0),
            ),
          ],
        ),
      ),
    );
  }
}
