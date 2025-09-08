import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/auth/data/models/result_model.dart';
import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eefood/features/auth/presentation/widgets/auth_button.dart';
import 'package:eefood/features/auth/presentation/widgets/custom_dialog.dart';
import 'package:eefood/features/auth/presentation/widgets/custom_text_field.dart';
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
    Result<bool> isReset = await _resetPassword(widget.email, widget.otpCode, confirmPassController.text);
    (isReset.isSuccess && isReset.data == true) ?
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: "Success",
          description: "Your password has been updated",
          buttonText: "Go to Home",
          imageLottie: "lotties/success_animation.json",
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      )
    : showCustomSnackBar(context, isReset.error!, isError: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                              icon: const Icon(Icons.arrow_back),
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
                            const Text(
                              'Create new password',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Enter your new password below',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),
                            CustomTextField(
                              labelText: 'Password',
                              controller: passController,
                              isPassword: true,
                              prefixIcon: const Icon(Icons.lock),
                              borderRadius: 8,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Password cannot be empty";
                                }
                                if (value.length < 6) {
                                  return "Password must be at least 6 characters";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            CustomTextField(
                              labelText: 'Confirm password',
                              controller: confirmPassController,
                              isPassword: true,
                              prefixIcon: const Icon(Icons.lock),
                              borderRadius: 8,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Confirm password cannot be empty";
                                }
                                if (value != passController.text) {
                                  return "Passwords do not match";
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
                text: 'Confirm',
                onPressed: () => _onConfirmPressed(context),
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
