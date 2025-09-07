import 'package:eefood/features/auth/domain/entities/otp.dart';

enum OtpType {
  REGISTER,
  FORGOT_PASSWORD
}

class OtpModel {
  final String email;
  final String otpCode;
  final OtpType otpType;

  OtpModel({required this.email, required this.otpCode, required this.otpType});

  factory OtpModel.fromJson(Map<String,dynamic> json) {
    return OtpModel(email: json['email'] as String, 
                    otpCode: json['otpCode'] as String, 
                    otpType: json['otpType'] as OtpType);
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otpCode': otpCode,
      'otpType': otpType
    };
  }

  Otp toEntity() => Otp(
    email: email,
    otpCode: otpCode,
    otpType: otpType
  );
}
