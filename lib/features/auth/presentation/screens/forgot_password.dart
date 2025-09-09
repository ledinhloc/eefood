import 'package:eefood/app_routes.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/helpers.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/auth/data/models/otp_model.dart';
import 'package:eefood/features/auth/data/models/result_model.dart';
import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eefood/features/auth/presentation/widgets/auth_button.dart';
import 'package:eefood/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({super.key});

  final ForgotPassword _forgotPassword = getIt<ForgotPassword>();
  final emailController = TextEditingController(text: 'ledinhloc7@gmail.com');

  void _fetchApiForgotPassword(BuildContext context) async {
    final String email = emailController.text;

    if (!isValidEmail(email)) {
      showCustomSnackBar(context, 'Email không hợp lệ', isError: true);
      return;
    }
    try {
      Result<bool> forgotPass = await _forgotPassword(email);

      (forgotPass.data == true && forgotPass.isSuccess)
          ? Navigator.pushNamed(context,AppRoutes.verifyOtp,
              arguments: {
                'email': emailController.text.trim(),
                'otpType': OtpType.FORGOT_PASSWORD,
              },
            )
          : showCustomSnackBar(context, forgotPass.error!, isError: true);
    } catch (e) {
      showCustomSnackBar(context, 'Forgot password failed: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController(text: 'ledinhloc7@gmail.com');

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                            'Forgot password',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Please enter your email.\nWe will send an OTP code for verification',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          CustomTextField(
                            controller: emailController,
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            enableClear: true,
                            borderRadius: 8,
                            fillColor: Colors.black,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AuthButton(
                text: 'Confirm',
                onPressed: () async {
                  _fetchApiForgotPassword(context);
                },
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
