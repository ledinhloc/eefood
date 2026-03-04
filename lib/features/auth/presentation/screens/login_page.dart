import 'dart:developer' as develop;

import 'package:eefood/app_routes.dart';
import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/core/widgets/loading_overlay.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/auth/domain/usecases/google_service.dart';
import 'package:eefood/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:eefood/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                    icon: Icon(
                      Icons.arrow_back,
                      color: theme.colorScheme.onSurface,
                    ),
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
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    l10n.signInTitle, // key: signIn
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email
                  CustomTextField(
                    controller: emailController,
                    labelText: l10n.email, // key: email
                    prefixIcon: Icon(
                      Icons.email,
                      color: theme.colorScheme.onSurface,
                    ),
                    enableClear: true,
                    borderRadius: 8,
                    fillColor: theme.colorScheme.onSurface,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 10),

                  // Password
                  CustomTextField(
                    controller: passController,
                    labelText: l10n.password, // key: password
                    isPassword: true,
                    prefixIcon: Icon(
                      Icons.lock,
                      color: theme.colorScheme.onSurface,
                    ),
                    suffixIcon: Icon(
                      Icons.visibility_off,
                      color: theme.colorScheme.onSurface,
                    ),
                    borderRadius: 8,
                    fillColor: theme.colorScheme.onSurface,
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
                            Text(
                              l10n.rememberMe, // key: rememberMe
                              style: theme.textTheme.bodySmall?.copyWith(
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
                        child: Text(
                          l10n.forgotPassword, // key: forgotPassword
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Sign in button
                  AuthButton(
                    text: l10n.signInTitle, // key: signIn
                    onPressed: _handleLogin,
                  ),

                  const SizedBox(height: 20),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: theme.colorScheme.outlineVariant),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Text(
                              l10n.orContinueWith, // key: orContinueWith
                              style: theme.textTheme.bodySmall?.copyWith(
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
                              child: Text(
                                l10n.signUp, // key: signUp
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Divider(color: theme.colorScheme.outlineVariant),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Google button
                  AuthButton(
                    text: l10n.continueWithGoogle, // key: continueWithGoogle
                    iconImage: const AssetImage('assets/images/google.png'),
                    iconSize: 20,
                    onPressed: _handleLoginGoogle,
                    color: theme.colorScheme.surface,
                    textColor: theme.colorScheme.onSurface,
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
