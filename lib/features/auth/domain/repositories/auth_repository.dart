import 'package:eefood/features/auth/data/models/UserModel.dart';
import 'package:eefood/features/auth/data/models/otp_model.dart';
import 'package:eefood/features/auth/data/models/register_response_model.dart';
import 'package:eefood/features/auth/data/models/response_data_model.dart';

import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<void> refreshToken();
  Future<User> getProfile();
  Future<ResponseDataModel<RegisterResponseModel>> register(String username, String email, String password);
  Future<ResponseDataModel<bool>> verifyOtp(String email, String otpCode, OtpType otpType);
  Future<ResponseDataModel<bool>> forgotPassword(String email);
  Future<ResponseDataModel<bool>> resetPassword(String email, String otpCode, String newPassword);
}