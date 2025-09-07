import 'package:eefood/app_routes.dart';
import 'package:eefood/features/auth/presentation/screens/reset_password.dart';
import 'package:eefood/features/auth/presentation/widgets/auth_button.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';

class VerificationOtpPage extends StatelessWidget {
  const VerificationOtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
    const fillColor = Color.fromRGBO(243, 246, 249, 0);

    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color.fromARGB(102, 134, 137, 137)),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
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
                          'https://lottie.host/8c506999-9e99-4acd-915e-26e35638551e/qKkVNi5Kf6.json',
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          'Verification OTP',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Check your email and enter\n a code below',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Pinput(
                          length: 6,
                          autofocus: true,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              border: Border.all(color: focusedBorderColor),
                            ),
                          ),
                          submittedPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              color: fillColor,
                              border: Border.all(color: focusedBorderColor),
                            ),
                          ),
                          errorPinTheme: defaultPinTheme.copyBorderWith(
                            border: Border.all(color: Colors.redAccent),
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Didn’t receive email?',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.only(
                            bottom: 2, // Space between underline and text
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.black45,
                                width: 1.0, // Underline thickness
                              ),
                            ),
                          ),
                          child: Text(
                            'Get OTP again',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AuthButton(
                text: 'Confirm',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.resetPassword);
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
