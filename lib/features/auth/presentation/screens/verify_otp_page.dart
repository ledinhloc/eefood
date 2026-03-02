import 'dart:async';

import 'package:eefood/app_routes.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/auth/data/models/otp_model.dart';
import 'package:eefood/features/auth/data/models/result_model.dart';
import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eefood/features/auth/presentation/widgets/auth_button.dart';
import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';

class VerificationOtpPage extends StatefulWidget {
  final String email;
  final OtpType otpType;

  const VerificationOtpPage({
    super.key,
    required this.email,
    required this.otpType,
  });

  @override
  State<VerificationOtpPage> createState() => _VerificationOtpPageState();
}

class _VerificationOtpPageState extends State<VerificationOtpPage> {
  final VerifyOtp _verifyOtp = getIt<VerifyOtp>();
  final ForgotPassword _forgotPassword = getIt<ForgotPassword>();
  final TextEditingController _otpController = TextEditingController();
  Timer? _timer;
  int _remainingSeconds = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _remainingSeconds = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  void _fetchApiResentOtp() async {
    try {
      Result<bool> isResent = await _forgotPassword(widget.email);
      if (isResent.isFailure) {
        showCustomSnackBar(context, isResent.error!, isError: true);
      } else {
        _startCountdown();
      }
    } catch (e) {
      showCustomSnackBar(context, 'Resent OTP failed $e', isError: true);
    }
  }

  void _fetchApiVerifyOtp() async {
    final l10n = AppLocalizations.of(context)!;
    final otpCode = _otpController.text;

    if (otpCode.length != 6) {
      showCustomSnackBar(
        context,
        l10n.otpInvalid,
        isError: true,
      ); // key: otpInvalid
      return;
    }
    try {
      Result<bool> isVerified = await _verifyOtp(
        widget.email,
        otpCode,
        widget.otpType,
      );
      if (isVerified.isFailure) {
        showCustomSnackBar(context, isVerified.error!, isError: true);
      } else {
        showCustomSnackBar(
          context,
          l10n.otpVerifiedSuccess, // key: otpVerifiedSuccess
          isError: false,
        );
        widget.otpType == OtpType.FORGOT_PASSWORD
            ? Navigator.pushNamed(
                context,
                AppRoutes.resetPassword,
                arguments: {'email': widget.email, 'otpCode': otpCode},
              )
            : Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
      }
    } catch (e) {
      showCustomSnackBar(
        context,
        l10n.otpVerifiedFailed, // key: otpVerifiedFailed
        isError: true,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
    const fillColor = Color.fromRGBO(243, 246, 249, 0);

    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: TextStyle(fontSize: 22, color: theme.colorScheme.onSurface),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.4)),
      ),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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
                        child: Lottie.network(
                          'https://lottie.host/8c506999-9e99-4acd-915e-26e35638551e/qKkVNi5Kf6.json',
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        children: [
                          Text(
                            l10n.verificationOtp, // key: verificationOtp
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.verificationOtpSubtitle, // key: verificationOtpSubtitle
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),

                          // OTP input
                          Pinput(
                            length: 6,
                            controller: _otpController,
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

                          const SizedBox(height: 15),

                          // Countdown / Resend
                          _remainingSeconds > 0
                              ? Text(
                                  l10n.otpResendCountdown(
                                    _remainingSeconds,
                                  ), // key: otpResendCountdown
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              : GestureDetector(
                                  onTap: () {
                                    // TODO: gọi API resend OTP ở đây
                                    _startCountdown();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.45),
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      l10n.otpGetAgain, // key: otpGetAgain
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Poppins',
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
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
                text: l10n.confirm, // key: confirm (đã có)
                onPressed: _fetchApiVerifyOtp,
                textColor: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
