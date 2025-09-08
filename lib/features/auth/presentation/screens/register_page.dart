import 'package:eefood/app_routes.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/auth/data/models/otp_model.dart';
import 'package:eefood/features/auth/data/models/register_response_model.dart';
import 'package:eefood/features/auth/data/models/result_model.dart';
import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eefood/features/auth/presentation/widgets/auth_button.dart';
import 'package:eefood/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});
  final Register _register = getIt<Register>();
  final nameController = TextEditingController(text: 'khoa');
  final emailController = TextEditingController(text: 'anhkhoadevtool2109@gmail.com');
  final passController = TextEditingController(text: '12345678');

  _fetchApiRegister(BuildContext context) async {
    try {
      Result<RegisterResponseModel> result = await _register(
        nameController.text,
        emailController.text,
        passController.text,
      );
      print(result.data);
      if (result.isFailure) {
        showCustomSnackBar(context, result.error!, isError: true);
      } else {
        Navigator.pushNamed(
          context,
          AppRoutes.verifyOtp,
          arguments: {
            'email': emailController.text.trim(),
            'otpType': OtpType.REGISTER,
          },
        );
      }
    } catch (e) {
      showCustomSnackBar(context, 'Register failed $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                  const SizedBox(height: 10),
                  const Text(
                    'Sign up',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: nameController,
                    labelText: 'Username',
                    prefixIcon: const Icon(Icons.account_circle_rounded),
                    enableClear: true,
                    borderRadius: 8,
                    fillColor: Colors.black,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 10),
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

                  const SizedBox(height: 20),
                  /*
                  Sign in Button
                  */
                  AuthButton(text: 'Sign up', onPressed: () async {
                    await _fetchApiRegister(context);
                  }),
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      Expanded(child: Divider(color: Colors.grey)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'or continue with',
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AuthButton(
                    text: 'Continue with Google',
                    iconImage: const AssetImage('assets/images/google.png'),
                    iconSize: 20,
                    onPressed: () {},
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
