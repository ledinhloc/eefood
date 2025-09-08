import 'package:eefood/features/auth/data/models/otp_model.dart';

class Otp {
  final String email;
  final String otpCode;
  final OtpType otpType;

  const Otp({required this.email, required this.otpCode, required this.otpType});
}