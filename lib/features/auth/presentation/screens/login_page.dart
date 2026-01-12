import 'dart:developer' as develop;

import 'package:eefood/app_routes.dart';
import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/core/widgets/loading_overlay.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/auth/domain/usecases/google_service.dart';
import 'package:eefood/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/logger.dart';
import '../../../noti/presentation/provider/notification_settings_cubit.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../widgets/auth_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginGoogle _loginGoogle = getIt<LoginGoogle>();
  final SharedPreferences _sharedPreferences = getIt<SharedPreferences>();
  final Login _login = getIt<Login>();
  final NotificationSettingsCubit notificationSettingsCubit =
  getIt<NotificationSettingsCubit>();

  final emailController = TextEditingController();

  final passController = TextEditingController();
  final authorRepo = getIt<AuthRepository>();
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final saved = await authorRepo.loadPassword();
    if (saved != null) {
      emailController.text = saved['email']!;
      passController.text = saved['password']!;
      setState(() => rememberMe = true);
    }
  }

  Future<void> _handleLoginGoogle() async {
    try {
      final isFirstLogin = _sharedPreferences.getBool(AppKeys.isLoginedIn);
      LoadingOverlay().show();
      final idToken = await GoogleAuthService.signInWithGoogle();
      if (idToken == null) {
        showCustomSnackBar(context, "Bạn đã hủy đăng nhập");
        return;
      }
      User user = await _loginGoogle(idToken);
      if (user.allergies!.isEmpty &&
          user.eatingPreferences!.isEmpty &&
          isFirstLogin!) {
        Navigator.pushReplacementNamed(context, AppRoutes.onBoardingFlow);
        return;
      }
      print(user);

      await notificationSettingsCubit.fetchSettings();

      Navigator.pushNamed(context, AppRoutes.main);
    } catch (err) {
      // print('Failed: $err');
      if (!mounted) return;
      showCustomSnackBar(context, "Vui lòng đăng nhập bằng gmail khác !");
      logger.i('Failed: $err');
    } finally {
      LoadingOverlay().hide();
    }
  }

  Future<void> _handleLogin() async {
    try {
      final isFirstLogin = _sharedPreferences.getBool(AppKeys.isLoginedIn);
      LoadingOverlay().show();
      User user = await _login(emailController.text, passController.text);

      if (rememberMe) {
        await authorRepo.savePassword(
          emailController.text,
          passController.text,
        );
      } else {
        await authorRepo.clearSavedPassword();
      }

      if (user.allergies!.isEmpty &&
          user.eatingPreferences!.isEmpty &&
          isFirstLogin!) {
        Navigator.pushReplacementNamed(context, AppRoutes.onBoardingFlow);
        return;
      }

      await notificationSettingsCubit.fetchSettings();

      Navigator.pushNamed(context, AppRoutes.main);
    } catch (e) {
      showCustomSnackBar(context, 'Đăng nhập không thành công!', isError: true);
      develop.log('Login failed: $e', name: 'Login Error');
      // showCustomSnackBar(context, 'Login failed: $e', isError: true);
    } finally {
      LoadingOverlay().hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ],
              ),
            ),

            // Top image (Lottie)
            SizedBox(
              height: 220,
              width: double.infinity,
              child: Center(
                child: Lottie.network(
                  'https://lottie.host/87078e48-ace6-4a3f-beb0-506b31bd1fe1/kebynmuvD5.json',
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
            ),

            // Login form
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Sign in',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email
                  CustomTextField(
                    controller: emailController,
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    enableClear: true,
                    borderRadius: 8,
                    fillColor: Colors.black,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 10),

                  // Password
                  CustomTextField(
                    controller: passController,
                    labelText: 'Password',
                    isPassword: true,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: const Icon(Icons.visibility_off),
                    borderRadius: 8,
                    fillColor: Colors.black,
                    maxLines: 1,
                  ),

                  const SizedBox(height: 10),

                  // Remember me + Forgot password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  rememberMe = value ?? false;
                                });
                              },
                            ),
                            const Text(
                              'Remember me',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.forgotPassword,
                          );
                        },
                        child: const Text(
                          'Forgot password',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Sign in button
                  AuthButton(text: 'Sign in', onPressed: _handleLogin),

                  const SizedBox(height: 20),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Colors.grey)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            const Text(
                              'or continue with? ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.register,
                                );
                              },
                              child: const Text(
                                'Sign up',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Expanded(child: Divider(color: Colors.grey)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Google button
                  AuthButton(
                    text: 'Continue with Google',
                    iconImage: const AssetImage('assets/images/google.png'),
                    iconSize: 20,
                    onPressed: _handleLoginGoogle,
                    color: Colors.white,
                    textColor: Colors.black,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
