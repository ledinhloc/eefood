import 'package:eefood/app_routes.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/auth/data/models/result_model.dart';
import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eefood/features/auth/presentation/widgets/auth_button.dart';
import 'package:eefood/features/auth/presentation/widgets/custom_dialog.dart';
import 'package:eefood/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String otpCode;
  const ResetPasswordPage({
    super.key,
    required this.email,
    required this.otpCode,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();
  final ResetPassword _resetPassword = getIt<ResetPassword>();

  @override
  void dispose() {
    passController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  void _onConfirmPressed(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      _fetchApiRestPassword();
    }
  }

  void _fetchApiRestPassword() async {
    final l10n = AppLocalizations.of(context)!;
    Result<bool> isReset = await _resetPassword(
      widget.email,
      widget.otpCode,
      confirmPassController.text,
    );
    (isReset.isSuccess && isReset.data == true)
        ? showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => CustomDialog(
              title: l10n
                  .resetPasswordSuccessTitle, // key: resetPasswordSuccessTitle
              description: l10n
                  .resetPasswordSuccessDesc, // key: resetPasswordSuccessDesc
              imageLottie: "assets/lotties/success_animation.json",
              buttons: [
                DialogButton(
                  text: l10n.goToHome, // key: goToHome
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                ),
              ],
            ),
          )
        : showCustomSnackBar(context, isReset.error!, isError: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
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

                      // Animation
                      SizedBox(
                        height: 220,
                        width: double.infinity,
                        child: Center(
                          child: Lottie.asset(
                            'assets/lotties/reset_password.json',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      // Fields
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: Column(
                          children: [
                            Text(
                              l10n.createNewPassword, // key: createNewPassword
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              l10n.createNewPasswordSubtitle, // key: createNewPasswordSubtitle
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),
                            CustomTextField(
                              labelText: l10n.password, // key: password (đã có)
                              controller: passController,
                              isPassword: true,
                              prefixIcon: Icon(
                                Icons.lock,
                                color: theme.colorScheme.onSurface,
                              ),
                              borderRadius: 8,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n
                                      .passwordEmpty; // key: passwordEmpty
                                }
                                if (value.length < 8) {
                                  return l10n
                                      .passwordTooShort; // key: passwordTooShort
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            CustomTextField(
                              labelText:
                                  l10n.confirmPassword, // key: confirmPassword
                              controller: confirmPassController,
                              isPassword: true,
                              prefixIcon: Icon(
                                Icons.lock,
                                color: theme.colorScheme.onSurface,
                              ),
                              borderRadius: 8,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n
                                      .confirmPasswordEmpty; // key: confirmPasswordEmpty
                                }
                                if (value != passController.text) {
                                  return l10n
                                      .passwordsDoNotMatch; // key: passwordsDoNotMatch
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Confirm button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AuthButton(
                text: l10n.confirm, // key: confirm (đã có)
                onPressed: () => _onConfirmPressed(context),
                textColor: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
