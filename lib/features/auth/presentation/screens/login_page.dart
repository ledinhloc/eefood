import 'package:dio/dio.dart';
import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:eefood/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../widgets/auth_button.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final Login _login = getIt<Login>();
  final emailControler = TextEditingController(text: 'ledinhloc7@gmail.com');

  final passControler = TextEditingController(text: '12345678');
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
                  child: Image.asset(
                    'assets/images/bg_login.png',
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
                      'Sign in',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: emailControler,
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      enableClear: true,
                      borderRadius: 8,
                      fillColor: Colors.black,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: passControler,
                      labelText: 'Password',
                      isPassword: true,
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: const Icon(Icons.visibility_off),

                      borderRadius: 8,
                      fillColor: Colors.black,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Checkbox(value: false, onChanged: (value) {}),
                              const Text(
                                'Remember me',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot password',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    /*
                    Sign in Button
                    */
                    AuthButton(
                      text: 'Sign in',
                      onPressed: () async {
                        try{
                          User user = await _login(emailControler.text, passControler.text);
                          // Navigator.pushReplacementNamed(context, '/home');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return MyApp();
                              },
                            ),
                          );
                        }catch(e){
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(content: Text('Login failed')),
                          // );
                          showCustomSnackBar(context, 'Login failed', isError: true);
                        }
                      },
                    ),
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
