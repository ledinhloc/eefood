import 'package:eefood/app_routes.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/loading_overlay.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/auth/data/models/otp_model.dart';
import 'package:eefood/features/auth/domain/entities/user.dart';
import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eefood/features/auth/domain/usecases/google_service.dart';
import 'package:eefood/features/auth/presentation/bloc/register_bloc/register_cubit.dart';
import 'package:eefood/features/auth/presentation/bloc/register_bloc/register_state.dart';
import 'package:eefood/features/auth/presentation/widgets/auth_button.dart';
import 'package:eefood/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/utils/logger.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});
  final LoginGoogle _loginGoogle = getIt<LoginGoogle>();
  final Register _register = getIt<Register>();
  final nameController = TextEditingController(text: 'khoa');
  final emailController = TextEditingController(text: 'anhkhoaxn11@gmail.com');
  final passController = TextEditingController(text: '12345678');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return BlocProvider(
      create: (_) => RegisterCubit(_register),
      child: BlocListener<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is RegisterFailure) {
            showCustomSnackBar(context, state.error, isError: true);
          }
          if (state is RegisterSuccess) {
            Navigator.pushNamed(
              context,
              AppRoutes.verifyOtp,
              arguments: {
                'email': emailController.text.trim(),
                'otpType': OtpType.REGISTER,
              },
            );
          }
        },
        child: BlocBuilder<RegisterCubit, RegisterState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Back button
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 7,
                            horizontal: 2,
                          ),
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

                        // Top image
                        SizedBox(
                          height: 220,
                          width: double.infinity,
                          child: Center(
                            child: Lottie.network(
                              'https://lottie.host/a9171100-df7a-414e-a585-1bb91b2b15cc/OSPEu04zmQ.json',
                              fit: BoxFit.contain,
                              width: double.infinity,
                            ),
                          ),
                        ),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
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
                              const SizedBox(height: 10),
                              Text(
                                l10n.signUp, // key: signUp
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 10),
                              CustomTextField(
                                controller: nameController,
                                labelText: l10n.username, // key: username
                                prefixIcon: Icon(
                                  Icons.account_circle_rounded,
                                  color: theme.colorScheme.onSurface,
                                ),
                                enableClear: true,
                                borderRadius: 8,
                                fillColor: theme.colorScheme.onSurface,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 10),
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

                              const SizedBox(height: 20),

                              // Sign up button
                              AuthButton(
                                text: l10n.signUp, // key: signUp
                                onPressed: () {
                                  context.read<RegisterCubit>().register(
                                    nameController.text,
                                    emailController.text,
                                    passController.text,
                                  );
                                },
                              ),

                              const SizedBox(height: 20),

                              // Divider
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: theme.colorScheme.outlineVariant,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      l10n.orContinueWith, // key: orContinueWith
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Poppins',
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: theme.colorScheme.outlineVariant,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Google button
                              AuthButton(
                                text: l10n
                                    .continueWithGoogle, // key: continueWithGoogle
                                iconImage: const AssetImage(
                                  'assets/images/google.png',
                                ),
                                iconSize: 20,
                                onPressed: () async {
                                  try {
                                    LoadingOverlay().show();
                                    final idToken =
                                        await GoogleAuthService.signInWithGoogle();
                                    if (idToken == null) {
                                      showCustomSnackBar(
                                        context,
                                        "Bạn đã hủy đăng nhập",
                                      );
                                      return;
                                    }
                                    User user = await _loginGoogle(idToken);
                                    if (user.allergies!.isEmpty &&
                                        user.eatingPreferences!.isEmpty) {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        AppRoutes.onBoardingFlow,
                                      );
                                      return;
                                    }
                                    print(user);
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.main,
                                    );
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
                                color: theme.colorScheme.surface,
                                textColor: theme.colorScheme.onSurface,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Loading overlay
                  if (state is RegisterLoading)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 30),
                          child: SpinKitCircle(
                            color: Colors.orange,
                            size: 50.0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
