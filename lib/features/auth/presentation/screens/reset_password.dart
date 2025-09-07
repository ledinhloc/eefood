import 'package:eefood/features/auth/presentation/widgets/auth_button.dart';
import 'package:eefood/features/auth/presentation/widgets/custom_dialog.dart';
import 'package:eefood/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ResetPassword extends StatelessWidget {
  ResetPassword({super.key});
  final passControler = TextEditingController(text: '12345678');
  final confirmPassControler = TextEditingController(text: '12345678');
  @override
  Widget build(BuildContext context) {
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
                        child: Lottie.asset(
                          'assets/lotties/reset_password.json',
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
                            'Create new password',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Enter your new password below',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 30),
                          CustomTextField(
                            labelText: 'Password',
                            controller: passControler,
                            isPassword: true,
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: const Icon(Icons.visibility_off),
                            borderRadius: 8,
                            fillColor: Colors.black,
                            maxLines: 1,
                          ),
                          SizedBox(height: 15),
                          CustomTextField(
                            labelText: 'Confirm password',
                            controller: confirmPassControler,
                            isPassword: true,
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: const Icon(Icons.visibility_off),
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
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => CustomDialog(
                      title: "Success",
                      description: "Your password has been updated",
                      buttonText: "Go to Home",
                      imageLottie: "lotties/success_animation.json",
                      onPressed: () => {
                        Navigator.pop(context)
                      },
                    ),
                  );
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
