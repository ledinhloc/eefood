import 'package:eefood/features/auth/data/models/otp_model.dart';
import 'package:eefood/features/auth/data/models/register_response_model.dart';
import 'package:eefood/features/auth/data/models/result_model.dart';

import '../entities/user.dart';

abstract class AuthRepository { 
  Future<void> saveFirstLogin(bool firstLogin);
  Future<User> loginWithGoogle(String idToken);
  Future<User> login(String email, String password);
  Future<void> logout({String? provider});
  Future<User?> getCurrentUser();
  Future<void> refreshToken();
  Future<User> getProfile();
  Future<Result<RegisterResponseModel>> register(String username, String email, String password);
  Future<Result<bool>> verifyOtp(String email, String otpCode, OtpType otpType);
  Future<Result<bool>> forgotPassword(String email);
  Future<Result<bool>> resetPassword(String email, String otpCode, String newPassword);
}