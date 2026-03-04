import 'package:eefood/app_routes.dart';
import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/loading_overlay.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/auth/domain/entities/user.dart';
import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eefood/features/auth/domain/usecases/google_service.dart';
import 'package:eefood/features/auth/presentation/screens/login_page.dart';
import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/logger.dart';

class WelcomePage extends StatelessWidget {
  WelcomePage({super.key});

  final LoginGoogle _loginGoogle = getIt<LoginGoogle>();
  final SharedPreferences _sharedPreferences = getIt<SharedPreferences>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/images/bg_welcome.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Welcome text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.welcomeTo, // key: welcomeTo
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'eeFood',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.welcomeSubtitle, // key: welcomeSubtitle
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 100),

                // Google button
                ElevatedButton.icon(
                  onPressed: () async {
                    final isFirstLogin = _sharedPreferences.getBool(
                      AppKeys.isLoginedIn,
                    );
                    try {
                      LoadingOverlay().show();
                      final idToken =
                          await GoogleAuthService.signInWithGoogle();
                      if (idToken == null) {
                        showCustomSnackBar(context, "Bạn đã hủy đăng nhập");
                        return;
                      }
                      User user = await _loginGoogle(idToken);
                      if (isFirstLogin != null) {
                        if (user.allergies!.isEmpty &&
                            user.eatingPreferences!.isEmpty &&
                            isFirstLogin) {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.onBoardingFlow,
                          );
                          return;
                        }
                      }
                      print(user);
                      Navigator.pushNamed(context, AppRoutes.main);
                    } catch (err) {
                      showCustomSnackBar(
                        context,
                        "Vui lòng đăng nhập bằng gmail khác !",
                      );
                      logger.i('Failed: $err');
                    } finally {
                      LoadingOverlay().hide();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: Image.asset('assets/images/google.png', height: 24),
                  label: Text(
                    l10n.continueWithGoogle,
                  ), // key: continueWithGoogle (đã có)
                ),
                const SizedBox(height: 15),

                // Get Started button
                ElevatedButton(
                  onPressed: () {
                    logger.i("Guest vao app!!");
                    Navigator.pushReplacementNamed(context, AppRoutes.main);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    l10n.getStarted, // key: getStarted
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Already have account button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    l10n.alreadyHaveAccount,
                  ), // key: alreadyHaveAccount
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
