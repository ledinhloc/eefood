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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});
  final LoginGoogle _loginGoogle = getIt<LoginGoogle>();
  final Register _register = getIt<Register>();
  final nameController = TextEditingController(text: 'khoa');
  final emailController = TextEditingController(
    text: 'anhkhoadevtool2109@gmail.com',
  );
  final passController = TextEditingController(text: '12345678');

  @override
  Widget build(BuildContext context) {
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
              body: Stack(
                children: [
                  SingleChildScrollView(
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
                                prefixIcon: const Icon(
                                  Icons.account_circle_rounded,
                                ),
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
                              AuthButton(
                                text: 'Sign up',
                                onPressed: () {
                                  context.read<RegisterCubit>().register(
                                    nameController.text,
                                    emailController.text,
                                    passController.text,
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: const [
                                  Expanded(child: Divider(color: Colors.grey)),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
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
                                    print('Failed: $err');
                                  } finally {
                                    LoadingOverlay().hide();
                                  }
                                },
                                color: Colors.white,
                                textColor: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
