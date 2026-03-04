import 'package:eefood/app_routes.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/helpers.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/auth/data/models/otp_model.dart';
import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eefood/features/auth/presentation/bloc/forgot_password_bloc/forgot_password_cubit.dart';
import 'package:eefood/features/auth/presentation/bloc/forgot_password_bloc/forgot_password_state.dart';
import 'package:eefood/features/auth/presentation/widgets/auth_button.dart';
import 'package:eefood/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';

class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({super.key});

  final ForgotPassword _forgotPassword = getIt<ForgotPassword>();
  final emailController = TextEditingController(text: 'ledinhloc7@gmail.com');

  _validateEmail(String? email, AppLocalizations l10n) {
    if (email == null || email.isEmpty) {
      return l10n.emailEmpty;
    }
    if (!isValidEmail(email)) {
      return l10n.emailInvalid;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final emailController = TextEditingController(text: 'ledinhloc7@gmail.com');

    return BlocProvider(
      create: (_) => ForgotPasswordCubit(_forgotPassword),
      child: BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordFailure) {
            showCustomSnackBar(context, state.error, isError: true);
          }
          if (state is ForgotPasswordSuccess) {
            Navigator.pushNamed(
              context,
              AppRoutes.verifyOtp,
              arguments: {
                'email': emailController.text.trim(),
                'otpType': OtpType.FORGOT_PASSWORD,
              },
            );
          }
        },
        child: BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: Stack(
                children: [
                  SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
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
                                        onPressed: () =>
                                            Navigator.maybePop(context),
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
                                      'https://lottie.host/365fbefa-c236-4ca2-b613-809ba2caffd1/QEyAFz1TSQ.json',
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
                                  child: Column(
                                    children: [
                                      Text(
                                        l10n.forgotPassword, // key: forgotPassword
                                        style: theme.textTheme.displaySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Poppins',
                                            ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        l10n.forgotPasswordSubtitle, // key: forgotPasswordSubtitle
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Poppins',
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 10),
                                      CustomTextField(
                                        controller: emailController,
                                        validator: (value) =>
                                            _validateEmail(value!, l10n),
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
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Confirm button
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: AuthButton(
                            text: l10n.confirm, // key: confirm
                            onPressed: () {
                              context
                                  .read<ForgotPasswordCubit>()
                                  .forgotPassword(emailController.text);
                            },
                            textColor: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Loading overlay
                  if (state is ForgotPasswordLoading)
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
