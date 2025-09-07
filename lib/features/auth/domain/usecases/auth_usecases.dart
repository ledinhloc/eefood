import 'package:eefood/features/auth/data/models/UserModel.dart';
import 'package:eefood/features/auth/data/models/otp_model.dart';
import 'package:eefood/features/auth/data/models/response_data_model.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';
/*
  Use case auth
*/

/* use case: Login*/
class Login {
  final AuthRepository repository;
  Login(this.repository);
  /* gọi object như mot ham */
  Future<User> call(String email, String password) => repository.login(email, password);
}

class Logout {
  final AuthRepository repository;
  Logout(this.repository);
  Future<void> call() => repository.logout();
}

class GetCurrentUser {
  final AuthRepository repository;
  GetCurrentUser(this.repository);
  Future<User?> call() => repository.getCurrentUser();
}

class RefreshToken {
  final AuthRepository repository;
  RefreshToken(this.repository);
  Future<void> call() => repository.refreshToken();
}

class GetProfile {
  final AuthRepository repository;
  GetProfile(this.repository);
  Future<User> call() => repository.getProfile();
}

class Register {
  final AuthRepository repository;
  Register(this.repository);
  Future<ResponseDataModel<User>> call(String username, String email, String password) => repository.register(username, email, password);
}

class VerifyOtp {
  final AuthRepository repository;
  VerifyOtp(this.repository);
  Future<ResponseDataModel<bool>> call(String email, String otpCode, OtpType otpType) => repository.verifyOtp(email, otpCode, otpType);
}

class ForgotPassword {
  final AuthRepository repository;
  ForgotPassword(this.repository);
  Future<ResponseDataModel<bool>> call(String email) => repository.forgotPassword(email);
}

class ResetPassword {
  final AuthRepository repository;
  ResetPassword(this.repository);
  Future<ResponseDataModel<bool>> call(String email, String otpCode, String newPassword) => repository.resetPassword(email, otpCode, newPassword);
}